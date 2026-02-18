---
search:
  exclude: true
---
# Soluciones orientativas - Examen practico UD1 + UD2 (2026-01-21)

> Estas soluciones son orientativas. Se aceptan variantes equivalentes.

## Parte 1 - LXC

```bash
# Ejercicio 1.1
lxc launch ubuntu:24.04 ud1ud2-lab
# Ejercicio 1.2
lxc list
# Ejercicio 1.3
lxc exec ud1ud2-lab -- bash
# Ejercicio 1.3
mkdir -p ~/examen_ud1_ud2/{scripts,resultados,datos,cron}
# Ejercicio 1.7
cat <<'EOF' > ~/examen_ud1_ud2/datos/equipos.txt
# ip nombre disco ram
10.0.0.10 srv01 20 4
10.0.0.11 srv02 55 8
10.0.0.12 srv03 35 16
10.0.0.13 srv04 120 32
EOF
exit
# Ejercicio 1.4
{
cat <<'EOF'
lxc launch ubuntu:24.04 ud1ud2-lab
lxc list
lxc exec ud1ud2-lab -- bash
EOF
  lxc info ud1ud2-lab
} > /tmp/lxc.txt
# Ejercicio 1.4
lxc file push /tmp/lxc.txt ud1ud2-lab/root/examen_ud1_ud2/resultados/lxc.txt
# Ejercicio 1.6
lxc snapshot ud1ud2-lab inicio
# Ejercicio 1.8
lxc export ud1ud2-lab ~/ud1ud2-lab.tar.gz
```

## Parte 2 - Script principal: alertas de equipos

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
# Ejercicio 2.10
chmod u+x ~/examen_ud1_ud2/scripts/alertas_equipos.sh
# Ejercicio 2.9
~/examen_ud1_ud2/scripts/alertas_equipos.sh 40 > ~/examen_ud1_ud2/resultados/alertas.txt
# Ejercicio 2.10
cat ~/examen_ud1_ud2/scripts/alertas_equipos.sh > ~/examen_ud1_ud2/resultados/alertas_script.txt
```

## Parte 3 - Paqueteria y actualizaciones

```bash
{
  # Ejercicio 3.1
  echo "apt update"
  apt update
  # Ejercicio 3.2
  echo "apt install -y htop nginx"
  apt install -y htop nginx
  # Ejercicio 3.3 (paquetes con "ssh")
  echo "dpkg -l | grep -i ssh"
  dpkg -l | grep -i ssh
  # Ejercicio 3.3 (/bin/bash pertenece a...)
  echo "dpkg -S /bin/bash"
  dpkg -S /bin/bash
  # Ejercicio 3.3 (ficheros del paquete nginx)
  echo "dpkg -L nginx"
  dpkg -L nginx
  # Ejercicio 3.3 (limpiar huerfanos)
  echo "apt autoremove -y"
  apt autoremove -y
} > ~/examen_ud1_ud2/resultados/paqueteria.txt
```

## Parte 4 - Servicios systemd

```bash
{
  # Ejercicio 4.1
  systemctl status nginx --no-pager
  # Ejercicio 4.2
  systemctl disable --now nginx
  # Ejercicio 4.2
  systemctl status nginx --no-pager
  # Ejercicio 4.3
  journalctl -u nginx -n 20 --no-pager
  # Ejercicio 4.4
  systemctl get-default
} > ~/examen_ud1_ud2/resultados/servicios.txt
```

## Parte 5 - Procesos y señales

```bash
# Ejercicio 5.1
sleep 900 &
pid=$!
{
  # Ejercicio 5.1
  echo "PID: $pid"
  # Ejercicio 5.2
  ps -o pid,ni,cmd -p "$pid"
  # Ejercicio 5.2
  renice +5 -p "$pid"
  # Ejercicio 5.2
  ps -o pid,ni,cmd -p "$pid"
  # Ejercicio 5.3
  kill -TERM "$pid"
  # Ejercicio 5.3
  ps -p "$pid" || true
} > ~/examen_ud1_ud2/resultados/procesos.txt
```

## Parte 6 - Programacion de tareas

```bash
# Ejercicio 6.1
(crontab -l 2>/dev/null; echo "*/10 * * * * date >> $HOME/examen_ud1_ud2/cron/fechas.log") | crontab -
# Ejercicio 6.2
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
# Ejercicio 6.3
systemctl --user daemon-reload
# Ejercicio 6.3
systemctl --user enable --now mi-uptime.timer
# Ejercicio 6.3
systemctl --user list-timers | rg "mi-uptime.timer" > ~/examen_ud1_ud2/resultados/timers.txt
```

## Entrega final

Dentro del contenedor:

```bash
# Entrega 1
tar -czf ~/examen_ud1_ud2_entrega.tar.gz -C ~ examen_ud1_ud2
```

Desde el host:

```bash
# Entrega 2
lxc file pull ud1ud2-lab/root/examen_ud1_ud2_entrega.tar.gz .
```
