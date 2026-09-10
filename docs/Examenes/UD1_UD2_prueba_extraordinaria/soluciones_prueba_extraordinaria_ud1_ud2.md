---
search:
  exclude: true
---
# Soluciones orientativas - Prueba extraordinaria UD1 + UD2

> Estas soluciones son orientativas. Se aceptan variantes equivalentes si
> cumplen el enunciado, guardan evidencias claras y respetan las rutas pedidas.

## Parte 1 - Preparacion del laboratorio LXD/LXC

En el host:

```bash
lxc init ubuntu:24.04 extra-ud1ud2
lxc config set extra-ud1ud2 limits.memory 768MiB
lxc config set extra-ud1ud2 limits.cpu 1
lxc config set extra-ud1ud2 boot.autostart true
lxc start extra-ud1ud2
lxc list extra-ud1ud2
```

Antes de entrar al contenedor, comprobar que tiene red. Si no tiene IP, ruta
por defecto o resolucion DNS, `apt update` fallara.

```bash
lxc exec extra-ud1ud2 -- bash -lc 'ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com; ping -c 2 1.1.1.1'
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
lxc config device add extra-ud1ud2 eth0 nic nictype=bridged parent=lxdbr0 name=eth0

# Reiniciar red del contenedor y volver a comprobar.
lxc restart extra-ud1ud2
lxc exec extra-ud1ud2 -- bash -lc 'ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com; ping -c 2 1.1.1.1'
```

Si la red `lxdbr0` no existe, crearla y repetir la asignacion de `eth0`:

```bash
lxc network create lxdbr0 ipv4.address=auto ipv4.nat=true ipv6.address=none
lxc config device add extra-ud1ud2 eth0 nic nictype=bridged parent=lxdbr0 name=eth0
lxc restart extra-ud1ud2
```

Entrar al contenedor:

```bash
lxc exec extra-ud1ud2 -- bash
```

Dentro del contenedor:

```bash
mkdir -p ~/extra_ud1_ud2/{scripts,resultados,datos,cron}
exit
```

En el host, guardar evidencias y crear el snapshot:

```bash
{
  echo '$ lxc list extra-ud1ud2'
  lxc list extra-ud1ud2
  echo
  echo '$ lxc info extra-ud1ud2'
  lxc info extra-ud1ud2
  echo
  echo '$ lxc config get extra-ud1ud2 limits.memory'
  lxc config get extra-ud1ud2 limits.memory
  echo
  echo '$ lxc config get extra-ud1ud2 limits.cpu'
  lxc config get extra-ud1ud2 limits.cpu
  echo
  echo '$ lxc config get extra-ud1ud2 boot.autostart'
  lxc config get extra-ud1ud2 boot.autostart
  echo
  echo '$ lxc exec extra-ud1ud2 -- bash -lc "ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com"'
  lxc exec extra-ud1ud2 -- bash -lc 'ip -4 addr show eth0; ip route; getent hosts archive.ubuntu.com'
} > /tmp/lxc.txt

lxc file push /tmp/lxc.txt extra-ud1ud2/root/extra_ud1_ud2/resultados/lxc.txt
lxc snapshot extra-ud1ud2 base-extra
```

Entrar de nuevo para hacer el resto:

```bash
lxc exec extra-ud1ud2 -- bash
```

## Parte 2 - Datos y scripting en bash

Dentro del contenedor:

```bash
cat <<'EOF' > ~/extra_ud1_ud2/datos/servicios.txt
# ip nombre disco ram servicio puerto estado
10.10.0.31 web02 18 4 nginx 80 activo
10.10.0.32 app02 42 2 apache2 8080 mantenimiento
10.10.0.33 db02 60 8 mariadb 3306 activo
10.10.0.34 backup02 12 1 rsync 873 caido
10.10.0.35 cache02 xx 16 redis 6379 activo
10.10.0.36 monitor02 25 yy prometheus 9090 activo
10.10.0.37 proxy02 30 4 nginx ochenta activo
10.10.0.38 dns02 8 2 bind9 53 activo
EOF
```

`~/extra_ud1_ud2/scripts/auditoria_servicios.sh`:

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
estado_esperado=$3

if ! [[ $umbral_disco =~ ^[0-9]+$ && $umbral_ram =~ ^[0-9]+$ ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

if [[ -z $estado_esperado ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

datos="$HOME/extra_ud1_ud2/datos/servicios.txt"
csv="$HOME/extra_ud1_ud2/resultados/informe_servicios.csv"

if [[ ! -f $datos ]]; then
  echo "ERROR FICHERO"
  exit 1
fi

# Contadores y minimo de RAM.
n_validos=0
n_formato=0
n_datos=0
n_disco=0
n_ram=0
n_estado=0
min_ram=""
min_ram_nombre=""
min_ram_ip=""

echo "ip,nombre,disco,ram,servicio,puerto,tipo,estado" > "$csv"

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
  disco=${campos[2]}
  ram=${campos[3]}
  servicio=${campos[4]}
  puerto=${campos[5]}
  estado=${campos[6]}

  if ! [[ $disco =~ ^[0-9]+$ && $ram =~ ^[0-9]+$ && $puerto =~ ^[0-9]+$ ]]; then
    echo "ERROR DATOS: $nombre ($ip)"
    n_datos=$((n_datos + 1))
    continue
  fi

  case "$servicio" in
    nginx|apache2)
      tipo="web"
      ;;
    mariadb|mysql|postgresql|redis)
      tipo="datos"
      ;;
    rsync)
      tipo="copias"
      ;;
    bind9|dnsmasq)
      tipo="red"
      ;;
    *)
      tipo="otros"
      ;;
  esac

  echo "$ip,$nombre,$disco,$ram,$servicio,$puerto,$tipo,$estado" >> "$csv"
  n_validos=$((n_validos + 1))

  if (( disco < umbral_disco )); then
    echo "DISCO BAJO: $nombre ($ip) -> ${disco}GB"
    n_disco=$((n_disco + 1))
  fi

  if (( ram < umbral_ram )); then
    echo "RAM BAJA: $nombre ($ip) -> ${ram}GB"
    n_ram=$((n_ram + 1))
  fi

  if [[ $estado != "$estado_esperado" ]]; then
    echo "ESTADO INCORRECTO: $nombre -> $estado"
    n_estado=$((n_estado + 1))
  fi

  if [[ -z $min_ram || $ram -lt $min_ram ]]; then
    min_ram=$ram
    min_ram_nombre=$nombre
    min_ram_ip=$ip
  fi
done < "$datos"

echo "Resumen: $n_validos validos, $n_formato formato, $n_datos datos, $n_disco disco, $n_ram ram, $n_estado estado"
echo "Minima RAM: $min_ram_nombre ($min_ram_ip) -> ${min_ram}GB"
```

Ejecucion y evidencias:

```bash
chmod u+x ~/extra_ud1_ud2/scripts/auditoria_servicios.sh

~/extra_ud1_ud2/scripts/auditoria_servicios.sh 20 4 activo \
  > ~/extra_ud1_ud2/resultados/auditoria_20_4.txt

~/extra_ud1_ud2/scripts/auditoria_servicios.sh 30 8 activo \
  > ~/extra_ud1_ud2/resultados/auditoria_30_8.txt

cat ~/extra_ud1_ud2/scripts/auditoria_servicios.sh \
  > ~/extra_ud1_ud2/resultados/auditoria_script.txt
```

Salida esperada para `20 4 activo`:

```text
DISCO BAJO: web02 (10.10.0.31) -> 18GB
RAM BAJA: app02 (10.10.0.32) -> 2GB
ESTADO INCORRECTO: app02 -> mantenimiento
DISCO BAJO: backup02 (10.10.0.34) -> 12GB
RAM BAJA: backup02 (10.10.0.34) -> 1GB
ESTADO INCORRECTO: backup02 -> caido
ERROR DATOS: cache02 (10.10.0.35)
ERROR DATOS: monitor02 (10.10.0.36)
ERROR DATOS: proxy02 (10.10.0.37)
DISCO BAJO: dns02 (10.10.0.38) -> 8GB
RAM BAJA: dns02 (10.10.0.38) -> 2GB
Resumen: 5 validos, 0 formato, 3 datos, 3 disco, 3 ram, 2 estado
Minima RAM: backup02 (10.10.0.34) -> 1GB
```

Salida esperada para `30 8 activo`:

```text
DISCO BAJO: web02 (10.10.0.31) -> 18GB
RAM BAJA: web02 (10.10.0.31) -> 4GB
RAM BAJA: app02 (10.10.0.32) -> 2GB
ESTADO INCORRECTO: app02 -> mantenimiento
DISCO BAJO: backup02 (10.10.0.34) -> 12GB
RAM BAJA: backup02 (10.10.0.34) -> 1GB
ESTADO INCORRECTO: backup02 -> caido
ERROR DATOS: cache02 (10.10.0.35)
ERROR DATOS: monitor02 (10.10.0.36)
ERROR DATOS: proxy02 (10.10.0.37)
DISCO BAJO: dns02 (10.10.0.38) -> 8GB
RAM BAJA: dns02 (10.10.0.38) -> 2GB
Resumen: 5 validos, 0 formato, 3 datos, 3 disco, 4 ram, 2 estado
Minima RAM: backup02 (10.10.0.34) -> 1GB
```

Contenido esperado de `informe_servicios.csv` tras la ultima ejecucion:

```csv
ip,nombre,disco,ram,servicio,puerto,tipo,estado
10.10.0.31,web02,18,4,nginx,80,web,activo
10.10.0.32,app02,42,2,apache2,8080,web,mantenimiento
10.10.0.33,db02,60,8,mariadb,3306,datos,activo
10.10.0.34,backup02,12,1,rsync,873,copias,caido
10.10.0.38,dns02,8,2,bind9,53,red,activo
```

## Parte 3 - Paqueteria y servicios

Dentro del contenedor:

```bash
apt update
apt install -y nginx curl htop

cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Practica extraordinaria UD1 UD2</title>
</head>
<body>
  <h1>Practica extraordinaria UD1 UD2</h1>
  <p>Hostname: $(hostname)</p>
  <p>Fecha: $(date)</p>
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
  echo '$ apt install -y nginx curl htop'
  apt install -y nginx curl htop
  echo
  echo '$ dpkg -l | grep -Ei "nginx|curl|htop"'
  dpkg -l | grep -Ei "nginx|curl|htop"
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
  echo '$ systemctl restart nginx'
  systemctl restart nginx
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
} > ~/extra_ud1_ud2/resultados/servicios.txt 2>&1
```

## Parte 4 - Procesos y tareas programadas

```bash
sleep 500 &
pid_500=$!
sleep 700 &
pid_700=$!
sleep 900 &
pid_900=$!

{
  echo "PID sleep 500: $pid_500"
  echo "PID sleep 700: $pid_700"
  echo "PID sleep 900: $pid_900"
  echo
  echo '$ jobs -l'
  jobs -l
  echo
  echo '$ ps -o pid,ppid,ni,stat,cmd -p "$pid_500","$pid_700","$pid_900"'
  ps -o pid,ppid,ni,stat,cmd -p "$pid_500","$pid_700","$pid_900"
  echo
  echo '$ kill -l'
  kill -l
  echo
  echo '$ renice +10 -p "$pid_500"'
  renice +10 -p "$pid_500"
  echo
  echo '$ ps -o pid,ni,cmd -p "$pid_500"'
  ps -o pid,ni,cmd -p "$pid_500"
  echo
  echo '$ kill -TERM "$pid_700"'
  kill -TERM "$pid_700"
  sleep 1
  ps -p "$pid_700" || true
  echo
  echo '$ kill -KILL "$pid_900"'
  kill -KILL "$pid_900"
  sleep 1
  ps -p "$pid_900" || true
  echo
  echo '$ kill "$pid_500"'
  kill "$pid_500"
  sleep 1
  echo
  echo '$ pgrep -a sleep || true'
  pgrep -a sleep || true
} > ~/extra_ud1_ud2/resultados/procesos.txt 2>&1
```

Cron del usuario actual:

```bash
{
  crontab -l 2>/dev/null | \
    grep -v 'extra_ud1_ud2/cron/\(fechas\|carga\|host\)\.log'
  echo "*/20 * * * * date >> $HOME/extra_ud1_ud2/cron/fechas.log"
  echo "10 * * * * uptime >> $HOME/extra_ud1_ud2/cron/carga.log"
  echo "30 23 * * * hostname >> $HOME/extra_ud1_ud2/cron/host.log"
} | crontab -

crontab -l > ~/extra_ud1_ud2/cron/crontab.txt
```

## Parte 5 - Systemd timer y empaquetado final

Dentro del contenedor:

```bash
cat > /etc/systemd/system/resumen-extra.service <<'EOF'
[Unit]
Description=Resumen periodico de la prueba extraordinaria UD1 UD2

[Service]
Type=oneshot
ExecStart=/bin/bash -lc 'date >> /root/extra_ud1_ud2/cron/resumen.log; hostname >> /root/extra_ud1_ud2/cron/resumen.log; uptime >> /root/extra_ud1_ud2/cron/resumen.log'
EOF

cat > /etc/systemd/system/resumen-extra.timer <<'EOF'
[Unit]
Description=Timer del resumen extraordinaria UD1 UD2

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now resumen-extra.timer
systemctl start resumen-extra.service

cp /etc/systemd/system/resumen-extra.service ~/extra_ud1_ud2/cron/
cp /etc/systemd/system/resumen-extra.timer ~/extra_ud1_ud2/cron/

{
  echo '$ systemctl status resumen-extra.timer --no-pager'
  systemctl status resumen-extra.timer --no-pager
  echo
  echo '$ systemctl list-timers resumen-extra.timer --all --no-pager'
  systemctl list-timers resumen-extra.timer --all --no-pager
  echo
  echo '$ journalctl -u resumen-extra.service -n 20 --no-pager'
  journalctl -u resumen-extra.service -n 20 --no-pager
  echo
  echo '$ systemctl cat resumen-extra.service'
  systemctl cat resumen-extra.service
} > ~/extra_ud1_ud2/resultados/timer.txt 2>&1

tar -czf ~/extra_ud1_ud2_entrega.tar.gz -C ~ extra_ud1_ud2
tar -tzf ~/extra_ud1_ud2_entrega.tar.gz | head -n 50
```

Desde el host:

```bash
lxc file pull extra-ud1ud2/root/extra_ud1_ud2_entrega.tar.gz .
tar -tzf extra_ud1_ud2_entrega.tar.gz | head -n 50
```
