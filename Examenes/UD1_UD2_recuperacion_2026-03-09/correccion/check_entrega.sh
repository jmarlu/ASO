#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: check_entrega.sh <recuperacion_ud1_ud2_entrega.tar.gz>
EOF
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

TAR_FILE="$1"
if [[ ! -f "$TAR_FILE" ]]; then
  echo "No existe: $TAR_FILE" >&2
  exit 1
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

tar -xzf "$TAR_FILE" -C "$tmp_dir"

root_dir="$(find "$tmp_dir" -maxdepth 2 -type d -name 'recuperacion_ud1_ud2' | head -n1 || true)"
if [[ -z "$root_dir" ]]; then
  echo "ERROR: No existe la carpeta recuperacion_ud1_ud2 en el tarball."
  exit 1
fi

score=0
max=10

add_points() {
  local inc="$1"
  score=$(awk -v a="$score" -v b="$inc" 'BEGIN { printf "%.2f", a + b }')
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

has_fixed() {
  local file="$1"
  local text="$2"
  rg -q --fixed-strings "$text" "$file"
}

has_regex() {
  local file="$1"
  local text="$2"
  rg -q "$text" "$file"
}

dirs_ok=true
for dir in scripts resultados datos cron; do
  if [[ ! -d "$root_dir/$dir" ]]; then
    dirs_ok=false
    break
  fi
done

lxc_file="$root_dir/resultados/lxc.txt"
if [[ -f "$lxc_file" ]] \
  && has_regex "$lxc_file" 'rec-ud1ud2' \
  && has_regex "$lxc_file" 'Status:|RUNNING|Running'; then
  pass_part "Parte 1.1 (contenedor y arranque)" 0.25
else
  fail_part "Parte 1.1 (contenedor y arranque)"
fi

if [[ -f "$lxc_file" ]] \
  && has_regex "$lxc_file" '512(MB|MiB|M)' \
  && has_regex "$lxc_file" 'boot\.autostart|autostart'; then
  pass_part "Parte 1.2 (memoria y autostart)" 0.25
else
  fail_part "Parte 1.2 (memoria y autostart)"
fi

if [[ "$dirs_ok" == true && -f "$lxc_file" ]]; then
  pass_part "Parte 1.3 (estructura y evidencias)" 0.25
else
  fail_part "Parte 1.3 (estructura y evidencias)"
fi

if [[ -f "$lxc_file" ]] && has_regex "$lxc_file" 'snapshot|inicio'; then
  pass_part "Parte 1.4 (snapshot)" 0.25
else
  fail_part "Parte 1.4 (snapshot)"
fi

inventario_file="$root_dir/datos/inventario.txt"
script_file="$root_dir/scripts/revision_inventario.sh"
revision_file="$root_dir/resultados/revision_20.txt"
script_copy_file="$root_dir/resultados/revision_script.txt"
csv_file="$root_dir/resultados/resumen_inventario.csv"

if [[ -f "$inventario_file" ]] \
  && has_fixed "$inventario_file" '10.0.0.21 web01 12 4 nginx activo' \
  && has_fixed "$inventario_file" '10.0.0.23 db01 40 8 mariadb activo' \
  && has_fixed "$inventario_file" '10.0.0.27 mon01 30 yy prometheus activo'; then
  pass_part "Parte 2.1 (inventario)" 0.50
else
  fail_part "Parte 2.1 (inventario)"
fi

if [[ -f "$script_file" && -x "$script_file" ]] \
  && has_regex "$script_file" '^#!/usr/bin/env bash|^#!/bin/bash' \
  && has_fixed "$script_file" 'inventario.txt'; then
  pass_part "Parte 2.2 (script y permisos)" 0.75
else
  fail_part "Parte 2.2 (script y permisos)"
fi

if [[ -f "$revision_file" ]] \
  && has_fixed "$revision_file" 'Resumen: 5 validos, 0 formato, 2 datos, 3 disco, 2 ram, 2 no_operativo' \
  && has_fixed "$revision_file" 'Minimo disco: bk01 (10.0.0.25) -> 9GB'; then
  pass_part "Parte 2.3 (resumen y minimo)" 0.75
else
  fail_part "Parte 2.3 (resumen y minimo)"
fi

if [[ -f "$revision_file" ]] \
  && has_fixed "$revision_file" 'ERROR DATOS: cache01 (10.0.0.24)' \
  && has_fixed "$revision_file" 'ERROR DATOS: mon01 (10.0.0.27)'; then
  pass_part "Parte 2.4 (errores de datos)" 0.75
else
  fail_part "Parte 2.4 (errores de datos)"
fi

if [[ -f "$revision_file" ]] \
  && has_fixed "$revision_file" 'DISCO BAJO: web01 (10.0.0.21) -> 12GB' \
  && has_fixed "$revision_file" 'RAM BAJA: app01 (10.0.0.22) -> 2GB' \
  && has_fixed "$revision_file" 'SERVICIO NO OPERATIVO: bk01 -> caido'; then
  pass_part "Parte 2.5 (alertas y servicio)" 0.75
else
  fail_part "Parte 2.5 (alertas y servicio)"
fi

if [[ -f "$script_file" ]] \
  && has_regex "$script_file" '\bwhile\b' \
  && has_regex "$script_file" '\bif\b'; then
  pass_part "Parte 2.6 (estructuras de control)" 0.50
else
  fail_part "Parte 2.6 (estructuras de control)"
fi

if [[ -f "$csv_file" ]] \
  && has_fixed "$csv_file" 'ip,nombre,disco,ram,servicio,tipo,estado' \
  && has_fixed "$csv_file" '10.0.0.23,db01,40,8,mariadb,datos,activo' \
  && has_fixed "$csv_file" '10.0.0.25,bk01,9,1,rsync,copias,caido'; then
  pass_part "Parte 2.7 (CSV)" 0.50
else
  fail_part "Parte 2.7 (CSV)"
fi

if [[ -f "$script_copy_file" && -s "$script_copy_file" ]]; then
  pass_part "Parte 2.8 (copia del script)" 0.50
else
  fail_part "Parte 2.8 (copia del script)"
fi

servicios_file="$root_dir/resultados/servicios.txt"
if [[ -f "$servicios_file" ]] \
  && has_regex "$servicios_file" 'upgradable|packages can be upgraded' \
  && has_regex "$servicios_file" 'nginx' \
  && has_regex "$servicios_file" 'curl'; then
  pass_part "Parte 3.1 (actualizacion e instalacion)" 0.50
else
  fail_part "Parte 3.1 (actualizacion e instalacion)"
fi

if [[ -f "$servicios_file" ]] && has_fixed "$servicios_file" 'Recuperacion UD1 UD2'; then
  pass_part "Parte 3.2 (web personalizada)" 0.50
else
  fail_part "Parte 3.2 (web personalizada)"
fi

if [[ -f "$servicios_file" ]] \
  && has_regex "$servicios_file" 'Depends:' \
  && has_regex "$servicios_file" '/usr|/etc|/lib/systemd/system/nginx'; then
  pass_part "Parte 3.3 (consulta de paquetes)" 0.50
else
  fail_part "Parte 3.3 (consulta de paquetes)"
fi

if [[ -f "$servicios_file" ]] \
  && has_regex "$servicios_file" 'nginx\.service|Active:' \
  && has_regex "$servicios_file" 'LISTEN|:80' \
  && has_regex "$servicios_file" 'disabled|enabled' \
  && has_regex "$servicios_file" '\bcron\b'; then
  pass_part "Parte 3.4 (servicio, logs y red)" 0.50
else
  fail_part "Parte 3.4 (servicio, logs y red)"
fi

procesos_file="$root_dir/resultados/procesos.txt"
crontab_file="$root_dir/cron/crontab.txt"

if [[ -f "$procesos_file" ]] \
  && has_fixed "$procesos_file" 'sleep 600' \
  && has_fixed "$procesos_file" 'sleep 900' \
  && has_regex "$procesos_file" 'renice| NI ' \
  && has_regex "$procesos_file" 'SIGTERM|TERM|kill -TERM' \
  && has_regex "$procesos_file" 'SIGKILL|KILL|kill -KILL'; then
  pass_part "Parte 4.1 (procesos y senales)" 0.50
else
  fail_part "Parte 4.1 (procesos y senales)"
fi

if [[ -f "$crontab_file" ]] \
  && has_fixed "$crontab_file" '*/15 * * * * date >> $HOME/recuperacion_ud1_ud2/cron/fechas.log' \
  && has_fixed "$crontab_file" '5 * * * * uptime >> $HOME/recuperacion_ud1_ud2/cron/carga.log'; then
  pass_part "Parte 4.2 (cron)" 0.50
else
  fail_part "Parte 4.2 (cron)"
fi

estado_service="$root_dir/cron/estado.service"
estado_timer="$root_dir/cron/estado.timer"
timer_file="$root_dir/resultados/timer.txt"

if [[ -f "$estado_service" && -f "$estado_timer" ]] \
  && has_fixed "$estado_service" 'estado.log' \
  && has_fixed "$estado_service" 'date' \
  && has_fixed "$estado_service" 'uptime' \
  && has_fixed "$estado_timer" 'OnCalendar=' \
  && has_fixed "$estado_timer" 'Persistent=true'; then
  pass_part "Parte 5.1 (service y timer)" 0.50
else
  fail_part "Parte 5.1 (service y timer)"
fi

if [[ -f "$timer_file" ]] \
  && has_fixed "$timer_file" 'estado.timer' \
  && has_fixed "$timer_file" 'estado.service'; then
  pass_part "Parte 5.2 (evidencias del timer)" 0.50
else
  fail_part "Parte 5.2 (evidencias del timer)"
fi

echo "Puntuacion: $score/$max"
