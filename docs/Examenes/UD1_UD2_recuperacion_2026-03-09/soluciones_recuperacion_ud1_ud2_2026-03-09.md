---
search:
  exclude: true
---
# Soluciones orientativas - Examen de recuperacion UD1 + UD2 (2026-03-09)

> Estas soluciones son orientativas. Se aceptan variantes equivalentes si
> cumplen el enunciado, dejan evidencias claras y usan las rutas pedidas.

## Parte 1 - Preparacion del laboratorio LXD/LXC

En el host:

```bash
# Crear el contenedor sin arrancarlo todavia
lxc init ubuntu:24.04 rec-ud1ud2
lxc config set rec-ud1ud2 limits.memory 512MiB
lxc config set rec-ud1ud2 boot.autostart true
lxc start rec-ud1ud2
lxc list rec-ud1ud2
lxc exec rec-ud1ud2 -- bash
```

Dentro del contenedor:

```bash
mkdir -p ~/recuperacion_ud1_ud2/{scripts,resultados,datos,cron}
exit
```

En el host, guardar evidencias y crear el snapshot:

```bash
{
  echo '$ lxc info rec-ud1ud2'
  lxc info rec-ud1ud2
  echo
  echo '$ lxc config get rec-ud1ud2 limits.memory'
  lxc config get rec-ud1ud2 limits.memory
  echo
  echo '$ lxc config get rec-ud1ud2 boot.autostart'
  lxc config get rec-ud1ud2 boot.autostart
  echo
  echo '$ lxc snapshot rec-ud1ud2 inicio'
  lxc snapshot rec-ud1ud2 inicio
} > /tmp/lxc.txt

lxc file push /tmp/lxc.txt \
  rec-ud1ud2/root/recuperacion_ud1_ud2/resultados/lxc.txt
```

## Parte 2 - Datos y scripting en bash

Dentro del contenedor:

```bash
cat <<'EOF' > ~/recuperacion_ud1_ud2/datos/inventario.txt
# ip nombre disco ram servicio estado
10.0.0.21 web01 12 4 nginx activo
10.0.0.22 app01 28 2 apache2 mantenimiento
10.0.0.23 db01 40 8 mariadb activo
10.0.0.24 cache01 xx 16 redis activo
10.0.0.25 bk01 9 1 rsync caido
10.0.0.26 api01 18 6 nginx activo
10.0.0.27 mon01 30 yy prometheus activo
EOF
```

`~/recuperacion_ud1_ud2/scripts/revision_inventario.sh`:

```bash
#!/usr/bin/env bash
set -u

# Validaciones de entrada.
if [[ $# -ne 2 ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

umbral_disco=$1
umbral_ram=$2

if ! [[ $umbral_disco =~ ^[0-9]+$ && $umbral_ram =~ ^[0-9]+$ ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

inventario="$HOME/recuperacion_ud1_ud2/datos/inventario.txt"
salida_csv="$HOME/recuperacion_ud1_ud2/resultados/resumen_inventario.csv"

if [[ ! -f $inventario ]]; then
  echo "ERROR FICHERO"
  exit 1
fi

# Contadores y cabecera CSV.
n_validos=0
n_formato=0
n_datos=0
n_disco=0
n_ram=0
n_no_operativo=0
min_nombre=""
min_ip=""
min_disco=""

echo "ip,nombre,disco,ram,servicio,tipo,estado" > "$salida_csv"

linea_num=0
while IFS= read -r linea; do
  linea_num=$((linea_num + 1))
  [[ -z $linea || ${linea:0:1} == "#" ]] && continue

  read -r -a campos <<< "$linea"
  if [[ ${#campos[@]} -ne 6 ]]; then
    echo "ERROR FORMATO: linea $linea_num"
    n_formato=$((n_formato + 1))
    continue
  fi

  ip=${campos[0]}
  nombre=${campos[1]}
  disco=${campos[2]}
  ram=${campos[3]}
  servicio=${campos[4]}
  estado=${campos[5]}

  if ! [[ $disco =~ ^[0-9]+$ && $ram =~ ^[0-9]+$ ]]; then
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
    *)
      tipo="otros"
      ;;
  esac

  echo "$ip,$nombre,$disco,$ram,$servicio,$tipo,$estado" >> "$salida_csv"
  n_validos=$((n_validos + 1))

  if (( disco < umbral_disco )); then
    echo "DISCO BAJO: $nombre ($ip) -> ${disco}GB"
    n_disco=$((n_disco + 1))
  fi

  if (( ram < umbral_ram )); then
    echo "RAM BAJA: $nombre ($ip) -> ${ram}GB"
    n_ram=$((n_ram + 1))
  fi

  if [[ $estado != "activo" ]]; then
    echo "SERVICIO NO OPERATIVO: $nombre -> $estado"
    n_no_operativo=$((n_no_operativo + 1))
  fi

  if [[ -z $min_disco || $disco -lt $min_disco ]]; then
    min_disco=$disco
    min_nombre=$nombre
    min_ip=$ip
  fi
done < "$inventario"

echo "Resumen: $n_validos validos, $n_formato formato, $n_datos datos, $n_disco disco, $n_ram ram, $n_no_operativo no_operativo"
echo "Minimo disco: $min_nombre ($min_ip) -> ${min_disco}GB"
```

Ejecutar y guardar evidencias:

```bash
chmod u+x ~/recuperacion_ud1_ud2/scripts/revision_inventario.sh
~/recuperacion_ud1_ud2/scripts/revision_inventario.sh 20 4 \
  > ~/recuperacion_ud1_ud2/resultados/revision_20.txt
cat ~/recuperacion_ud1_ud2/scripts/revision_inventario.sh \
  > ~/recuperacion_ud1_ud2/resultados/revision_script.txt
```

Salida esperada principal:

```text
DISCO BAJO: web01 (10.0.0.21) -> 12GB
RAM BAJA: app01 (10.0.0.22) -> 2GB
SERVICIO NO OPERATIVO: app01 -> mantenimiento
ERROR DATOS: cache01 (10.0.0.24)
DISCO BAJO: bk01 (10.0.0.25) -> 9GB
RAM BAJA: bk01 (10.0.0.25) -> 1GB
SERVICIO NO OPERATIVO: bk01 -> caido
DISCO BAJO: api01 (10.0.0.26) -> 18GB
ERROR DATOS: mon01 (10.0.0.27)
Resumen: 5 validos, 0 formato, 2 datos, 3 disco, 2 ram, 2 no_operativo
Minimo disco: bk01 (10.0.0.25) -> 9GB
```

## Parte 3 - Paqueteria y servicios

Dentro del contenedor:

```bash
hostname_actual="$(hostname)"

cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Recuperacion UD1 UD2</title>
</head>
<body>
  <h1>Recuperacion UD1 UD2</h1>
  <p>$hostname_actual</p>
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
  echo '$ apt install -y nginx curl'
  apt install -y nginx curl
  echo
  echo '$ dpkg -l | rg -i "ssh|nginx|curl"'
  dpkg -l | rg -i "ssh|nginx|curl"
  echo
  echo '$ apt-cache search nginx | head'
  apt-cache search nginx | head
  echo
  echo '$ apt-cache depends nginx'
  apt-cache depends nginx
  echo
  echo '$ apt show nginx'
  apt show nginx
  echo
  echo '$ dpkg -L nginx | head -n 40'
  dpkg -L nginx | head -n 40
  echo
  echo '$ systemctl status nginx --no-pager'
  systemctl status nginx --no-pager
  echo
  echo '$ journalctl -u nginx -n 20 --no-pager'
  journalctl -u nginx -n 20 --no-pager
  echo
  echo '$ ss -ltnp | rg ":80"'
  ss -ltnp | rg ":80"
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
  echo '$ ss -ltnp | rg ":80"'
  ss -ltnp | rg ":80"
} > ~/recuperacion_ud1_ud2/resultados/servicios.txt 2>&1
```

## Parte 4 - Procesos y tareas programadas

```bash
sleep 600 &
pid_600=$!
sleep 900 &
pid_900=$!

{
  echo "PID sleep 600: $pid_600"
  echo "PID sleep 900: $pid_900"
  echo
  jobs -l
  echo
  ps -o pid,ni,cmd -p "$pid_600","$pid_900"
  echo
  kill -l
  echo
  renice +5 -p "$pid_600"
  echo
  ps -o pid,ni,cmd -p "$pid_600"
  echo
  kill -TERM "$pid_900"
  sleep 1
  ps -p "$pid_900" || true
  echo
  kill -KILL "$pid_600"
  sleep 1
  ps -p "$pid_600" || true
} > ~/recuperacion_ud1_ud2/resultados/procesos.txt 2>&1
```

Cron del usuario actual:

```bash
{
  crontab -l 2>/dev/null | \
    sed '/recuperacion_ud1_ud2\/cron\/\(fechas\|carga\)\.log/d'
  echo "*/15 * * * * date >> $HOME/recuperacion_ud1_ud2/cron/fechas.log"
  echo "5 * * * * uptime >> $HOME/recuperacion_ud1_ud2/cron/carga.log"
} | crontab -

crontab -l > ~/recuperacion_ud1_ud2/cron/crontab.txt
```

## Parte 5 - Systemd timer y empaquetado final

Dentro del contenedor:

```bash
cat > /etc/systemd/system/estado.service <<'EOF'
[Unit]
Description=Guardar estado periodico para la recuperacion UD1 UD2

[Service]
Type=oneshot
ExecStart=/bin/bash -lc 'date >> /root/recuperacion_ud1_ud2/cron/estado.log; uptime >> /root/recuperacion_ud1_ud2/cron/estado.log'
EOF

cat > /etc/systemd/system/estado.timer <<'EOF'
[Unit]
Description=Timer de estado para la recuperacion UD1 UD2

[Timer]
OnCalendar=*:0/30
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now estado.timer
systemctl start estado.service

cp /etc/systemd/system/estado.service ~/recuperacion_ud1_ud2/cron/
cp /etc/systemd/system/estado.timer ~/recuperacion_ud1_ud2/cron/

{
  systemctl status estado.timer --no-pager
  echo
  systemctl list-timers estado.timer --all --no-pager
  echo
  journalctl -u estado.service -n 20 --no-pager
} > ~/recuperacion_ud1_ud2/resultados/timer.txt

tar -czf ~/recuperacion_ud1_ud2_entrega.tar.gz -C ~ recuperacion_ud1_ud2
```

Desde el host:

```bash
lxc file pull rec-ud1ud2/root/recuperacion_ud1_ud2_entrega.tar.gz .
```
