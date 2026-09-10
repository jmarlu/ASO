---
search:
  exclude: true
---
# Soluciones orientativas - Mock extraordinaria UD1 + UD2 (2026-06-12)

> Estas soluciones son orientativas. Se aceptan variantes equivalentes si
> cumplen el enunciado, guardan evidencias claras y respetan las rutas pedidas.

## Parte 1 - Preparacion del laboratorio LXD/LXC

En el host:

```bash
lxc init ubuntu:24.04 mock-extra-ud1ud2
lxc config set mock-extra-ud1ud2 limits.memory 640MiB
lxc config set mock-extra-ud1ud2 limits.cpu 1
lxc config set mock-extra-ud1ud2 boot.autostart true
lxc start mock-extra-ud1ud2
lxc list mock-extra-ud1ud2
```

Antes de entrar al contenedor, comprobar que tiene red. Si no tiene IP, ruta
por defecto o resolucion DNS, `apt update` fallara.

```bash
lxc exec mock-extra-ud1ud2 -- bash -lc 'ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com; ping -c 2 1.1.1.1'
```

Si falla porque el contenedor no tiene interfaz de red o no sale a Internet,
reparar la red desde el host:

```bash
# Comprobar que existe la red bridge de LXD.
lxc network list

# Si lxdbr0 existe, asegurarse de que hace NAT.
lxc network set lxdbr0 ipv4.nat true
lxc network set lxdbr0 dns.mode managed

# Si el contenedor no tiene eth0, anadir una tarjeta a lxdbr0.
lxc config device add mock-extra-ud1ud2 eth0 nic nictype=bridged parent=lxdbr0 name=eth0

# Reiniciar red del contenedor y volver a comprobar.
lxc restart mock-extra-ud1ud2
lxc exec mock-extra-ud1ud2 -- bash -lc 'ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com; ping -c 2 1.1.1.1'
```

Si la red `lxdbr0` no existe, crearla y repetir la asignacion de `eth0`:

```bash
lxc network create lxdbr0 ipv4.address=auto ipv4.nat=true ipv6.address=none
lxc config device add mock-extra-ud1ud2 eth0 nic nictype=bridged parent=lxdbr0 name=eth0
lxc restart mock-extra-ud1ud2
```

Entrar al contenedor:

```bash
lxc exec mock-extra-ud1ud2 -- bash
```

Dentro del contenedor:

```bash
mkdir -p ~/mock_extra_ud1_ud2/{scripts,resultados,datos,cron}
exit
```

En el host, guardar evidencias y crear el snapshot:

```bash
{
  echo '$ lxc list mock-extra-ud1ud2'
  lxc list mock-extra-ud1ud2
  echo
  echo '$ lxc info mock-extra-ud1ud2'
  lxc info mock-extra-ud1ud2
  echo
  echo '$ lxc config get mock-extra-ud1ud2 limits.memory'
  lxc config get mock-extra-ud1ud2 limits.memory
  echo
  echo '$ lxc config get mock-extra-ud1ud2 limits.cpu'
  lxc config get mock-extra-ud1ud2 limits.cpu
  echo
  echo '$ lxc config get mock-extra-ud1ud2 boot.autostart'
  lxc config get mock-extra-ud1ud2 boot.autostart
  echo
  echo '$ lxc config show mock-extra-ud1ud2 --expanded | sed -n "/profiles:/,$p"'
  lxc config show mock-extra-ud1ud2 --expanded | sed -n '/profiles:/,$p'
  echo
  echo '$ lxc exec mock-extra-ud1ud2 -- bash -lc "ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com"'
  lxc exec mock-extra-ud1ud2 -- bash -lc 'ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com'
} > /tmp/lxc.txt

lxc file push /tmp/lxc.txt \
  mock-extra-ud1ud2/root/mock_extra_ud1_ud2/resultados/lxc.txt

lxc snapshot mock-extra-ud1ud2 inicio-mock
```

Entrar de nuevo para hacer el resto:

```bash
lxc exec mock-extra-ud1ud2 -- bash
```

## Parte 2 - Datos y scripting en bash

Dentro del contenedor:

```bash
cat <<'EOF' > ~/mock_extra_ud1_ud2/datos/nodos.txt
# ip nombre rol disco ram estado puerto
10.20.0.11 web-a web 14 4 activo 80
10.20.0.12 web-b web 28 2 mantenimiento 8080
10.20.0.13 db-a datos 45 8 activo 3306
10.20.0.14 backup-a copias 18 1 caido 873
10.20.0.15 cache-a cache xx 16 activo 6379
10.20.0.16 monitor-a monitor 30 yy activo 9090
10.20.0.17 proxy-a red 22 4 activo ochenta
10.20.0.18 dns-a red 9 2 activo 53
10.20.0.19 app-a app 35 6 degradado 9000
EOF
```

`~/mock_extra_ud1_ud2/scripts/revision_nodos.sh`:

```bash
#!/usr/bin/env bash
set -u

# Validacion de argumentos.
if [[ $# -ne 3 ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

umbral_disco=$1
umbral_ram=$2
estado_correcto=$3

if ! [[ $umbral_disco =~ ^[0-9]+$ && $umbral_ram =~ ^[0-9]+$ ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

if [[ -z $estado_correcto ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

datos="$HOME/mock_extra_ud1_ud2/datos/nodos.txt"
csv="$HOME/mock_extra_ud1_ud2/resultados/resumen_nodos.csv"

if [[ ! -f $datos ]]; then
  echo "ERROR FICHERO"
  exit 1
fi

# Contadores y valores minimos.
n_validos=0
n_formato=0
n_datos=0
n_disco=0
n_ram=0
n_estado=0
min_disco=""
min_disco_nombre=""
min_disco_ip=""
min_ram=""
min_ram_nombre=""
min_ram_ip=""

echo "ip,nombre,rol,disco,ram,puerto,tipo,estado" > "$csv"

# Lectura y revision del fichero.
linea_num=0
while IFS= read -r linea; do
  linea_num=$((linea_num + 1))
  [[ -z $linea || ${linea:0:1} == "#" ]] && continue

  read -r -a campos <<< "$linea"
  if [[ ${#campos[@]} -ne 7 ]]; then
    echo "ERROR FORMATO: linea $linea_num"
    n_formato=$((n_formato + 1))
    continue
  fi

  ip=${campos[0]}
  nombre=${campos[1]}
  rol=${campos[2]}
  disco=${campos[3]}
  ram=${campos[4]}
  estado=${campos[5]}
  puerto=${campos[6]}

  if ! [[ $disco =~ ^[0-9]+$ && $ram =~ ^[0-9]+$ && $puerto =~ ^[0-9]+$ ]]; then
    echo "ERROR DATOS: $nombre ($ip)"
    n_datos=$((n_datos + 1))
    continue
  fi

  case "$rol" in
    web|app|proxy)
      tipo="frontend"
      ;;
    datos|cache)
      tipo="backend"
      ;;
    copias|red)
      tipo="infraestructura"
      ;;
    monitor)
      tipo="monitorizacion"
      ;;
    *)
      tipo="otros"
      ;;
  esac

  echo "$ip,$nombre,$rol,$disco,$ram,$puerto,$tipo,$estado" >> "$csv"
  n_validos=$((n_validos + 1))

  if (( disco < umbral_disco )); then
    echo "DISCO CRITICO: $nombre ($ip) -> ${disco}GB"
    n_disco=$((n_disco + 1))
  fi

  if (( ram < umbral_ram )); then
    echo "RAM CRITICA: $nombre ($ip) -> ${ram}GB"
    n_ram=$((n_ram + 1))
  fi

  if [[ $estado != "$estado_correcto" ]]; then
    echo "ESTADO REVISAR: $nombre -> $estado"
    n_estado=$((n_estado + 1))
  fi

  if [[ -z $min_disco || $disco -lt $min_disco ]]; then
    min_disco=$disco
    min_disco_nombre=$nombre
    min_disco_ip=$ip
  fi

  if [[ -z $min_ram || $ram -lt $min_ram ]]; then
    min_ram=$ram
    min_ram_nombre=$nombre
    min_ram_ip=$ip
  fi
done < "$datos"

echo "Resumen: $n_validos validos, $n_formato formato, $n_datos datos, $n_disco disco, $n_ram ram, $n_estado estado"
echo "Minimo disco: $min_disco_nombre ($min_disco_ip) -> ${min_disco}GB"
echo "Minima RAM: $min_ram_nombre ($min_ram_ip) -> ${min_ram}GB"
```

Ejecucion y evidencias:

```bash
chmod u+x ~/mock_extra_ud1_ud2/scripts/revision_nodos.sh

~/mock_extra_ud1_ud2/scripts/revision_nodos.sh 20 4 activo \
  > ~/mock_extra_ud1_ud2/resultados/revision_20_4.txt

~/mock_extra_ud1_ud2/scripts/revision_nodos.sh 30 8 activo \
  > ~/mock_extra_ud1_ud2/resultados/revision_30_8.txt

~/mock_extra_ud1_ud2/scripts/revision_nodos.sh 20 \
  > ~/mock_extra_ud1_ud2/resultados/revision_error_argumentos.txt

cat ~/mock_extra_ud1_ud2/scripts/revision_nodos.sh \
  > ~/mock_extra_ud1_ud2/resultados/revision_script.txt
```

Salida esperada para `20 4 activo`:

```text
DISCO CRITICO: web-a (10.20.0.11) -> 14GB
RAM CRITICA: web-b (10.20.0.12) -> 2GB
ESTADO REVISAR: web-b -> mantenimiento
DISCO CRITICO: backup-a (10.20.0.14) -> 18GB
RAM CRITICA: backup-a (10.20.0.14) -> 1GB
ESTADO REVISAR: backup-a -> caido
ERROR DATOS: cache-a (10.20.0.15)
ERROR DATOS: monitor-a (10.20.0.16)
ERROR DATOS: proxy-a (10.20.0.17)
DISCO CRITICO: dns-a (10.20.0.18) -> 9GB
RAM CRITICA: dns-a (10.20.0.18) -> 2GB
ESTADO REVISAR: app-a -> degradado
Resumen: 6 validos, 0 formato, 3 datos, 3 disco, 3 ram, 3 estado
Minimo disco: dns-a (10.20.0.18) -> 9GB
Minima RAM: backup-a (10.20.0.14) -> 1GB
```

Salida esperada para `30 8 activo`:

```text
DISCO CRITICO: web-a (10.20.0.11) -> 14GB
RAM CRITICA: web-a (10.20.0.11) -> 4GB
DISCO CRITICO: web-b (10.20.0.12) -> 28GB
RAM CRITICA: web-b (10.20.0.12) -> 2GB
ESTADO REVISAR: web-b -> mantenimiento
DISCO CRITICO: backup-a (10.20.0.14) -> 18GB
RAM CRITICA: backup-a (10.20.0.14) -> 1GB
ESTADO REVISAR: backup-a -> caido
ERROR DATOS: cache-a (10.20.0.15)
ERROR DATOS: monitor-a (10.20.0.16)
ERROR DATOS: proxy-a (10.20.0.17)
DISCO CRITICO: dns-a (10.20.0.18) -> 9GB
RAM CRITICA: dns-a (10.20.0.18) -> 2GB
RAM CRITICA: app-a (10.20.0.19) -> 6GB
ESTADO REVISAR: app-a -> degradado
Resumen: 6 validos, 0 formato, 3 datos, 4 disco, 5 ram, 3 estado
Minimo disco: dns-a (10.20.0.18) -> 9GB
Minima RAM: backup-a (10.20.0.14) -> 1GB
```

Contenido esperado de `resumen_nodos.csv` tras la ultima ejecucion:

```csv
ip,nombre,rol,disco,ram,puerto,tipo,estado
10.20.0.11,web-a,web,14,4,80,frontend,activo
10.20.0.12,web-b,web,28,2,8080,frontend,mantenimiento
10.20.0.13,db-a,datos,45,8,3306,backend,activo
10.20.0.14,backup-a,copias,18,1,873,infraestructura,caido
10.20.0.18,dns-a,red,9,2,53,infraestructura,activo
10.20.0.19,app-a,app,35,6,9000,frontend,degradado
```

## Parte 3 - Paqueteria y servicios

Dentro del contenedor:

```bash
apt update
apt install -y nginx curl htop tree

cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Mock extraordinaria UD1 UD2</title>
</head>
<body>
  <h1>Mock extraordinaria UD1 UD2</h1>
  <p>Hostname: $(hostname)</p>
  <p>Fecha: $(date)</p>
  <p>Usuario: $(whoami)</p>
</body>
</html>
EOF

{
  echo '$ apt update'
  apt update
  echo
  echo '$ apt list --upgradable'
  apt list --upgradable
  echo
  echo '$ apt install -y nginx curl htop tree'
  apt install -y nginx curl htop tree
  echo
  echo '$ dpkg -l | grep -Ei "nginx|curl|htop|tree"'
  dpkg -l | grep -Ei "nginx|curl|htop|tree"
  echo
  echo '$ apt-cache search nginx | head'
  apt-cache search nginx | head
  echo
  echo '$ apt-cache depends nginx'
  apt-cache depends nginx
  echo
  echo '$ apt show curl'
  apt show curl
  echo
  echo '$ dpkg -S /bin/bash'
  dpkg -S /bin/bash
  echo
  echo '$ dpkg -L nginx | head -n 60'
  dpkg -L nginx | head -n 60
  echo
  echo '$ systemctl status nginx --no-pager'
  systemctl status nginx --no-pager
  echo
  echo '$ journalctl -u nginx -n 20 --no-pager'
  journalctl -u nginx -n 20 --no-pager
  echo
  echo '$ ss -ltnp | grep ":80"'
  ss -ltnp | grep ':80'
  echo
  echo '$ systemctl get-default'
  systemctl get-default
  echo
  echo '$ systemctl status nginx cron --no-pager'
  systemctl status nginx cron --no-pager
  echo
  echo '$ curl -s http://127.0.0.1/'
  curl -s http://127.0.0.1/
  echo
  echo '$ systemctl disable nginx'
  systemctl disable nginx
  echo
  echo '$ systemctl stop nginx'
  systemctl stop nginx
  echo
  echo '$ systemctl start nginx'
  systemctl start nginx
  echo
  echo '$ systemctl is-enabled nginx'
  systemctl is-enabled nginx || true
  echo
  echo '$ systemctl status nginx --no-pager'
  systemctl status nginx --no-pager
  echo
  echo '$ ss -ltnp | grep ":80"'
  ss -ltnp | grep ':80'
  echo
  echo '$ curl -s http://127.0.0.1/'
  curl -s http://127.0.0.1/
} > ~/mock_extra_ud1_ud2/resultados/servicios.txt 2>&1
```

## Parte 4 - Procesos y tareas programadas

```bash
sleep 450 &
pid_450=$!
sleep 750 &
pid_750=$!
sleep 1050 &
pid_1050=$!

{
  echo "PID sleep 450: $pid_450"
  echo "PID sleep 750: $pid_750"
  echo "PID sleep 1050: $pid_1050"
  echo
  echo '$ jobs -l'
  jobs -l
  echo
  echo '$ ps -o pid,ppid,ni,stat,cmd -p "$pid_450","$pid_750","$pid_1050"'
  ps -o pid,ppid,ni,stat,cmd -p "$pid_450","$pid_750","$pid_1050"
  echo
  echo '$ kill -l'
  kill -l
  echo
  echo '$ renice +7 -p "$pid_450"'
  renice +7 -p "$pid_450"
  echo
  echo '$ ps -o pid,ni,cmd -p "$pid_450"'
  ps -o pid,ni,cmd -p "$pid_450"
  echo
  echo '$ kill -TERM "$pid_750"'
  kill -TERM "$pid_750"
  sleep 1
  ps -p "$pid_750" || true
  echo
  echo '$ kill -KILL "$pid_1050"'
  kill -KILL "$pid_1050"
  sleep 1
  ps -p "$pid_1050" || true
  echo
  echo '$ kill "$pid_450"'
  kill "$pid_450"
  sleep 1
  echo
  echo '$ pgrep -a sleep || true'
  pgrep -a sleep || true
} > ~/mock_extra_ud1_ud2/resultados/procesos.txt 2>&1
```

Cron del usuario actual:

```bash
{
  crontab -l 2>/dev/null | \
    grep -v 'mock_extra_ud1_ud2/cron/\(fechas\|carga\|host\)\.log'
  echo "*/12 * * * * date >> $HOME/mock_extra_ud1_ud2/cron/fechas.log"
  echo "7 * * * * uptime >> $HOME/mock_extra_ud1_ud2/cron/carga.log"
  echo "45 18 * * 1-5 hostname >> $HOME/mock_extra_ud1_ud2/cron/host.log"
} | crontab -

crontab -l > ~/mock_extra_ud1_ud2/cron/crontab.txt
```

## Parte 5 - Systemd timer y empaquetado final

Dentro del contenedor:

```bash
cat > /etc/systemd/system/informe-mock.service <<'EOF'
[Unit]
Description=Informe periodico del mock extraordinaria UD1 UD2

[Service]
Type=oneshot
ExecStart=/bin/bash -lc 'date >> /root/mock_extra_ud1_ud2/cron/informe.log; hostname >> /root/mock_extra_ud1_ud2/cron/informe.log; whoami >> /root/mock_extra_ud1_ud2/cron/informe.log; uptime >> /root/mock_extra_ud1_ud2/cron/informe.log'
EOF

cat > /etc/systemd/system/informe-mock.timer <<'EOF'
[Unit]
Description=Timer del informe mock extraordinaria UD1 UD2

[Timer]
OnCalendar=*:0/45
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now informe-mock.timer
systemctl start informe-mock.service

cp /etc/systemd/system/informe-mock.service ~/mock_extra_ud1_ud2/cron/
cp /etc/systemd/system/informe-mock.timer ~/mock_extra_ud1_ud2/cron/

{
  echo '$ systemctl status informe-mock.timer --no-pager'
  systemctl status informe-mock.timer --no-pager
  echo
  echo '$ systemctl list-timers informe-mock.timer --all --no-pager'
  systemctl list-timers informe-mock.timer --all --no-pager
  echo
  echo '$ journalctl -u informe-mock.service -n 20 --no-pager'
  journalctl -u informe-mock.service -n 20 --no-pager
  echo
  echo '$ systemctl cat informe-mock.service'
  systemctl cat informe-mock.service
  echo
  echo '$ cat ~/mock_extra_ud1_ud2/cron/informe.log'
  cat ~/mock_extra_ud1_ud2/cron/informe.log
} > ~/mock_extra_ud1_ud2/resultados/timer.txt 2>&1

tar -czf ~/mock_extra_ud1_ud2_entrega.tar.gz -C ~ mock_extra_ud1_ud2
tar -tzf ~/mock_extra_ud1_ud2_entrega.tar.gz | head -n 50
```

Desde el host:

```bash
lxc file pull mock-extra-ud1ud2/root/mock_extra_ud1_ud2_entrega.tar.gz .
```
