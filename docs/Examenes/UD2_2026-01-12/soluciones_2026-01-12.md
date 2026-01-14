---
search:
  exclude: true
---

# Soluciones examen practico UD2 (2026-01-12)

Nota: Las Partes 2 a 5 se ejecutan dentro del contenedor `ud2-lab`.

## Parte 1 - Laboratorio en LXC (2.0 pts)

En el host:

```bash
# Lanzar el contenedor
lxc launch images:ubuntu/24.04 ud2-lab

# Ver estado e IP
lxc list

# Entrar al contenedor
lxc exec ud2-lab -- bash
```

En el contenedor:

```bash
mkdir -p ~/examen_ud2/scripts ~/examen_ud2/resultados ~/examen_ud2/cron
```

En el host (para guardar evidencias):

```bash
# Crear el registro de la parte 1 dentro del contenedor
lxc info ud2-lab | lxc exec ud2-lab -- tee ~/examen_ud2/resultados/lxc.txt >/dev/null

# Snapshot
lxc snapshot ud2-lab inicio

# Exportacion
lxc export ud2-lab ~/ud2-lab.tar.gz
```

## Parte 2 - Paqueteria y actualizaciones (2.0 pts)

En el contenedor:

```bash
sudo apt update
sudo apt install -y htop nginx

{
  echo "sudo apt update"
  echo "sudo apt install -y htop nginx"
  echo "dpkg -l '*ssh*'"
  echo "dpkg -S /bin/bash"
  echo "dpkg -L nginx"
  echo "sudo apt autoremove"
} > ~/examen_ud2/resultados/paqueteria.txt
```

## Parte 3 - Servicios systemd (2.0 pts)

En el contenedor:

```bash
{
  systemctl status nginx --no-pager
  sudo systemctl disable nginx
  systemctl is-enabled nginx
  journalctl -u nginx -n 20 --no-pager
  systemctl get-default
} > ~/examen_ud2/resultados/servicios.txt
```

## Parte 4 - Procesos y senales (2.0 pts)

En el contenedor:

```bash
{
  sleep 900 &
  echo "PID=$!"
  sudo renice +5 -p $!
  ps -o pid,ni,cmd -p $!
  kill -TERM $!
  sleep 1
  pgrep -a sleep || true
} > ~/examen_ud2/resultados/procesos.txt
```

## Parte 5 - Programacion de tareas (2.0 pts)

En el contenedor:

```bash
# Cron del usuario actual
( crontab -l 2>/dev/null; echo "*/10 * * * * /usr/bin/date >> /home/$USER/examen_ud2/cron/fechas.log" ) | crontab -
crontab -l > ~/examen_ud2/cron/crontab.txt

# Systemd timer
cat <<'SERVICE' > ~/examen_ud2/cron/mi-uptime.service
[Unit]
Description=Registro horario de uptime

[Service]
Type=oneshot
ExecStart=/usr/bin/uptime >> /home/%u/examen_ud2/cron/uptime.log
SERVICE

cat <<'TIMER' > ~/examen_ud2/cron/mi-uptime.timer
[Unit]
Description=Ejecucion cada hora de mi-uptime

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
TIMER

sudo cp ~/examen_ud2/cron/mi-uptime.service /etc/systemd/system/mi-uptime.service
sudo cp ~/examen_ud2/cron/mi-uptime.timer /etc/systemd/system/mi-uptime.timer
sudo systemctl daemon-reload
sudo systemctl enable --now mi-uptime.timer
systemctl list-timers mi-uptime.timer --no-pager > ~/examen_ud2/resultados/timers.txt
```

## Entrega en Aules

En el contenedor:

```bash
tar -czf ~/examen_ud2_entrega.tar.gz -C ~ examen_ud2
```

En el host:

```bash
lxc file pull ud2-lab/home/$USER/examen_ud2_entrega.tar.gz .
```

Subir `examen_ud2_entrega.tar.gz` a Aules.
