#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <examen_ud1_ud2_entrega.tar.gz>"
  exit 1
fi

TAR_FILE="$1"
if [[ ! -f "$TAR_FILE" ]]; then
  echo "No existe: $TAR_FILE"
  exit 1
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

tar -xzf "$TAR_FILE" -C "$tmp_dir"

root_dir="$tmp_dir/examen_ud1_ud2"
if [[ ! -d "$root_dir" ]]; then
  echo "ERROR: No existe la carpeta examen_ud1_ud2 en el tarball."
  exit 1
fi

score=0
max=10

add_points() {
  local inc="$1"
  score=$(awk -v a="$score" -v b="$inc" 'BEGIN {printf "%.2f", a + b}')
}

pass_part() {
  local part="$1"
  local pts="$2"
  echo "[OK] $part (+$pts)"
  add_points "$pts"
}

fail_part() {
  local part="$1"
  echo "[NO] $part (+0)"
}

# Parte 1 - LXC
lxc_file="$root_dir/resultados/lxc.txt"
if [[ -f "$lxc_file" ]] \
  && rg -q "ud1ud2-lab" "$lxc_file" \
  && rg -q "lxc info" "$lxc_file"; then
  pass_part "Parte 1 (lxc.txt)" 1.5
else
  fail_part "Parte 1 (lxc.txt)"
fi

# Parte 2 - Datos
usuarios_file="$root_dir/datos/usuarios.txt"
equipos_file="$root_dir/datos/equipos.txt"
if [[ -f "$usuarios_file" && -f "$equipos_file" ]] \
  && rg -q "maria:1003" "$usuarios_file" \
  && rg -q "srv01" "$equipos_file"; then
  pass_part "Parte 2 (datos)" 1
else
  fail_part "Parte 2 (datos)"
fi

# Parte 3 - Script principal
script_file="$root_dir/scripts/alertas_equipos.sh"
alertas_file="$root_dir/resultados/alertas.txt"
alertas_script_file="$root_dir/resultados/alertas_script.txt"
if [[ -f "$script_file" && -f "$alertas_file" && -f "$alertas_script_file" ]] \
  && rg -q "Resumen:" "$alertas_file" \
  && [[ -s "$alertas_script_file" ]]; then
  pass_part "Parte 3 (script alertas)" 3
else
  fail_part "Parte 3 (script alertas)"
fi

# Parte 4 - Paqueteria
paq_file="$root_dir/resultados/paqueteria.txt"
if [[ -f "$paq_file" ]] \
  && rg -q "apt update" "$paq_file" \
  && rg -q "apt install" "$paq_file" \
  && rg -q "dpkg -S /bin/bash" "$paq_file"; then
  pass_part "Parte 4 (paqueteria.txt)" 1.5
else
  fail_part "Parte 4 (paqueteria.txt)"
fi

# Parte 5 - Servicios
serv_file="$root_dir/resultados/servicios.txt"
if [[ -f "$serv_file" ]] \
  && rg -q "nginx" "$serv_file" \
  && rg -q "systemctl" "$serv_file"; then
  pass_part "Parte 5 (servicios.txt)" 1
else
  fail_part "Parte 5 (servicios.txt)"
fi

# Parte 6 - Procesos
proc_file="$root_dir/resultados/procesos.txt"
if [[ -f "$proc_file" ]] \
  && rg -q "sleep 900" "$proc_file"; then
  pass_part "Parte 6 (procesos.txt)" 0.5
else
  fail_part "Parte 6 (procesos.txt)"
fi

# Parte 7 - Programacion
cron_file="$root_dir/cron/crontab.txt"
timer_file="$root_dir/resultados/timers.txt"
svc_file="$root_dir/cron/mi-uptime.service"
tmr_file="$root_dir/cron/mi-uptime.timer"
if [[ -f "$cron_file" && -f "$timer_file" && -f "$svc_file" && -f "$tmr_file" ]] \
  && rg -q "mi-uptime.timer" "$timer_file"; then
  pass_part "Parte 7 (cron + timer)" 1.5
else
  fail_part "Parte 7 (cron + timer)"
fi

echo "Puntuacion: $score/$max"
