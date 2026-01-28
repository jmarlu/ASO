---
search:
  exclude: true
---
# Soluciones orientativas - Examen practico UD1 + UD2 (2026-01-21)

> Estas soluciones son orientativas. Se aceptan variantes equivalentes.

## Parte 1 - LXC

```bash
lxc launch ubuntu:24.04 ud1ud2-lab
lxc list
lxc exec ud1ud2-lab -- bash
mkdir -p ~/examen_ud1_ud2/{scripts,resultados,datos,cron}
lxc info ud1ud2-lab > /tmp/lxc_info.txt
exit
cat <<'EOF' > /tmp/lxc_comandos.txt
lxc launch ubuntu:24.04 ud1ud2-lab
lxc list
lxc exec ud1ud2-lab -- bash
EOF
cat /tmp/lxc_comandos.txt /tmp/lxc_info.txt > /tmp/lxc.txt
lxc file push /tmp/lxc.txt ud1ud2-lab/root/examen_ud1_ud2/resultados/lxc.txt
lxc snapshot ud1ud2-lab inicio
lxc export ud1ud2-lab ~/ud1ud2-lab.tar.gz
```

## Parte 2 - Datos

```bash
cat <<'EOF' > ~/examen_ud1_ud2/datos/usuarios.txt
# usuario:uid:shell
root:0:/bin/bash
daemon:1:/usr/sbin/nologin
ana:1001:/bin/bash
pedro:1002:/bin/zsh
maria:1003:/bin/bash
EOF

cat <<'EOF' > ~/examen_ud1_ud2/datos/equipos.txt
# ip nombre disco ram
10.0.0.10 srv01 20 4
10.0.0.11 srv02 55 8
10.0.0.12 srv03 35 16
10.0.0.13 srv04 120 32
EOF
```

## Parte 3 - Script principal: alertas de equipos

`~/examen_ud1_ud2/scripts/alertas_equipos.sh`:

```bash
#!/usr/bin/env bash
set -u

if [[ $# -ne 1 ]]; then
  echo "ERROR ARGUMENTOS"
  exit 1
fi

umbral=$1
if ! [[ $umbral =~ ^[0-9]+$ ]]; then
  echo "ERROR ARGUMENTO"
  exit 1
fi

fichero="$HOME/examen_ud1_ud2/datos/equipos.txt"
if [[ ! -f $fichero ]]; then
  echo "ERROR FICHERO"
  exit 1
fi

n_discos=0
n_ram=0
n_err=0

while read -r ip nombre disco ram; do
  [[ -z ${ip:-} || ${ip:0:1} == "#" ]] && continue
  if ! [[ $disco =~ ^[0-9]+$ && $ram =~ ^[0-9]+$ ]]; then
    echo "ERROR DATOS: $nombre ($ip) valores no numericos"
    n_err=$((n_err + 1))
    continue
  fi
  if (( disco < umbral )); then
    echo "ALERTA: $nombre ($ip) tiene ${disco}GB libres (< ${umbral}GB)"
    n_discos=$((n_discos + 1))
  fi
  if (( ram < 8 )); then
    echo "AVISO RAM: $nombre ($ip) tiene ${ram}GB"
    n_ram=$((n_ram + 1))
  fi
done < "$fichero"

echo "Resumen: $n_discos alertas disco, $n_ram avisos RAM, $n_err errores"
```

Ejecucion:

```bash
chmod u+x ~/examen_ud1_ud2/scripts/alertas_equipos.sh
~/examen_ud1_ud2/scripts/alertas_equipos.sh 40 > ~/examen_ud1_ud2/resultados/alertas.txt
cat ~/examen_ud1_ud2/scripts/alertas_equipos.sh > ~/examen_ud1_ud2/resultados/alertas_script.txt
```

## Parte 4 - Paqueteria

```bash
{
  echo "apt update"
  apt update
  echo "apt install -y htop nginx"
  apt install -y htop nginx
  echo "dpkg -l | grep -i ssh"
  dpkg -l | grep -i ssh
  echo "dpkg -S /bin/bash"
  dpkg -S /bin/bash
  echo "dpkg -L nginx"
  dpkg -L nginx
  echo "apt autoremove -y"
  apt autoremove -y
} > ~/examen_ud1_ud2/resultados/paqueteria.txt
```

## Parte 5 - Servicios

```bash
{
  systemctl status nginx --no-pager
  systemctl disable --now nginx
  systemctl status nginx --no-pager
  journalctl -u nginx -n 20 --no-pager
  systemctl get-default
} > ~/examen_ud1_ud2/resultados/servicios.txt
```

## Parte 6 - Procesos

```bash
sleep 900 &
pid=$!
{
  echo "PID: $pid"
  ps -o pid,ni,cmd -p "$pid"
  renice +5 -p "$pid"
  ps -o pid,ni,cmd -p "$pid"
  kill -TERM "$pid"
  ps -p "$pid" || true
} > ~/examen_ud1_ud2/resultados/procesos.txt
```

## Parte 7 - Programacion de tareas

```bash
(crontab -l 2>/dev/null; echo "*/10 * * * * date >> $HOME/examen_ud1_ud2/cron/fechas.log") | crontab -
crontab -l > ~/examen_ud1_ud2/cron/crontab.txt
```

`~/examen_ud1_ud2/cron/mi-uptime.service`:

```ini
[Unit]
Description=Guardar uptime

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'uptime >> %h/examen_ud1_ud2/cron/uptime.log'
```

`~/examen_ud1_ud2/cron/mi-uptime.timer`:

```ini
[Unit]
Description=Timer uptime

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now mi-uptime.timer
systemctl --user list-timers | rg "mi-uptime.timer" > ~/examen_ud1_ud2/resultados/timers.txt
```
