#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: check_entrega.sh <ordinario_ud1_ud2_entrega.tar.gz>
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

if ! tar -xf "$TAR_FILE" -C "$tmp_dir" 2>/dev/null; then
  echo "ERROR: No se ha podido extraer la entrega: $TAR_FILE"
  exit 2
fi

root_dir="$(find "$tmp_dir" -maxdepth 2 -type d -name 'ordinario_ud1_ud2' | head -n1 || true)"
if [[ -z "$root_dir" ]]; then
  echo "ERROR: No existe la carpeta ordinario_ud1_ud2 en el tarball."
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
  local reason="${2:-}"
  if [[ -n "$reason" ]]; then
    echo "[NO] $part (+0) -> $reason"
  else
    echo "[NO] $part (+0)"
  fi
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

join_with() {
  local sep="$1"
  shift
  local joined=""
  local item
  for item in "$@"; do
    [[ -n "$item" ]] || continue
    if [[ -n "$joined" ]]; then
      joined+="$sep"
    fi
    joined+="$item"
  done
  printf '%s' "$joined"
}

join_messages() {
  join_with "; " "$@"
}

list_matching_files() {
  local dir="$1"
  local pattern="$2"
  local matches=()
  local match
  [[ -d "$dir" ]] || return 0
  while IFS= read -r match; do
    [[ -n "$match" ]] || continue
    matches+=("$match")
  done < <(find "$dir" -maxdepth 1 -type f -name "$pattern" -printf '%f\n' 2>/dev/null | sort)
  if [[ ${#matches[@]} -gt 0 ]]; then
    join_with ", " "${matches[@]}"
  fi
  return 0
}

extract_matching_lines() {
  local file="$1"
  local pattern="$2"
  local limit="${3:-3}"
  local lines=()
  local line
  [[ -f "$file" ]] || return 0
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    lines+=("$line")
    [[ ${#lines[@]} -ge "$limit" ]] && break
  done < <(rg -N "$pattern" "$file" 2>/dev/null || true)
  if [[ ${#lines[@]} -gt 0 ]]; then
    join_with " | " "${lines[@]}"
  fi
  return 0
}

first_line() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local line
  line="$(sed -n '1p' "$file")"
  if [[ -n "$line" ]]; then
    printf '%s' "$line"
  else
    printf '(vacia)'
  fi
}

file_mode() {
  local file="$1"
  [[ -e "$file" ]] || return 0
  stat -c '%A' "$file" 2>/dev/null || true
}

dirs_ok=true
missing_dirs=()
for dir in scripts resultados datos cron; do
  if [[ ! -d "$root_dir/$dir" ]]; then
    dirs_ok=false
    missing_dirs+=("$dir")
  fi
done

lxc_file="$root_dir/resultados/lxc.txt"
if [[ -f "$lxc_file" ]] \
  && has_regex "$lxc_file" 'ord-ud1ud2' \
  && has_regex "$lxc_file" 'Status:|RUNNING|Running'; then
  pass_part "Parte 1.1 (contenedor y arranque)" 0.25
else
  reasons=()
  [[ -f "$lxc_file" ]] || reasons+=("falta resultados/lxc.txt")
  { [[ -f "$lxc_file" ]] && has_regex "$lxc_file" 'ord-ud1ud2'; } || reasons+=("no aparece el nombre del contenedor ord-ud1ud2")
  { [[ -f "$lxc_file" ]] && has_regex "$lxc_file" 'Status:|RUNNING|Running'; } || reasons+=("no hay evidencia clara de arranque o estado en ejecucion")
  fail_part "Parte 1.1 (contenedor y arranque)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$lxc_file" ]] \
  && has_regex "$lxc_file" '512(MB|MiB|M)' \
  && has_regex "$lxc_file" 'boot\.autostart|autostart'; then
  pass_part "Parte 1.2 (memoria y autostart)" 0.25
else
  reasons=()
  [[ -f "$lxc_file" ]] || reasons+=("falta resultados/lxc.txt")
  { [[ -f "$lxc_file" ]] && has_regex "$lxc_file" '512(MB|MiB|M)'; } || reasons+=("no se detecta la configuracion de memoria a 512MB")
  { [[ -f "$lxc_file" ]] && has_regex "$lxc_file" 'boot\.autostart|autostart'; } || reasons+=("no hay evidencia de autostart")
  fail_part "Parte 1.2 (memoria y autostart)" "$(join_messages "${reasons[@]}")"
fi

if [[ "$dirs_ok" == true && -f "$lxc_file" ]]; then
  pass_part "Parte 1.3 (estructura y evidencias)" 0.25
else
  reasons=()
  [[ "$dirs_ok" == true ]] || reasons+=("faltan directorios obligatorios: ${missing_dirs[*]}")
  [[ -f "$lxc_file" ]] || reasons+=("falta resultados/lxc.txt")
  fail_part "Parte 1.3 (estructura y evidencias)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$lxc_file" ]] && has_regex "$lxc_file" 'snapshot|inicio'; then
  pass_part "Parte 1.4 (snapshot)" 0.25
else
  reasons=()
  [[ -f "$lxc_file" ]] || reasons+=("falta resultados/lxc.txt")
  { [[ -f "$lxc_file" ]] && has_regex "$lxc_file" 'snapshot|inicio'; } || reasons+=("no hay evidencia del snapshot inicio")
  fail_part "Parte 1.4 (snapshot)" "$(join_messages "${reasons[@]}")"
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
  reasons=()
  [[ -f "$inventario_file" ]] || reasons+=("falta datos/inventario.txt")
  { [[ -f "$inventario_file" ]] && has_fixed "$inventario_file" '10.0.0.21 web01 12 4 nginx activo'; } || reasons+=("no aparece la linea de web01 esperada")
  { [[ -f "$inventario_file" ]] && has_fixed "$inventario_file" '10.0.0.23 db01 40 8 mariadb activo'; } || reasons+=("no aparece la linea de db01 esperada")
  { [[ -f "$inventario_file" ]] && has_fixed "$inventario_file" '10.0.0.27 mon01 30 yy prometheus activo'; } || reasons+=("no aparece la linea de mon01 esperada")
  fail_part "Parte 2.1 (inventario)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$script_file" && -x "$script_file" ]] \
  && has_regex "$script_file" '^#!/usr/bin/env bash|^#!/bin/bash' \
  && has_fixed "$script_file" 'inventario.txt'; then
  pass_part "Parte 2.2 (script y permisos)" 0.75
else
  reasons=()
  [[ -f "$script_file" ]] || reasons+=("falta scripts/revision_inventario.sh")
  if [[ -f "$script_file" && ! -x "$script_file" ]]; then
    reasons+=("el script no tiene permisos de ejecucion; permisos actuales: $(file_mode "$script_file")")
  fi
  if [[ -f "$script_file" ]] && ! has_regex "$script_file" '^#!/usr/bin/env bash|^#!/bin/bash'; then
    reasons+=("no se detecta shebang de bash; primera linea actual: $(first_line "$script_file")")
  fi
  { [[ -f "$script_file" ]] && has_fixed "$script_file" 'inventario.txt'; } || reasons+=("el script no referencia inventario.txt")
  fail_part "Parte 2.2 (script y permisos)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$revision_file" ]] \
  && has_fixed "$revision_file" 'Resumen: 5 validos, 0 formato, 2 datos, 3 disco, 2 ram, 2 no_operativo' \
  && has_fixed "$revision_file" 'Minimo disco: bk01 (10.0.0.25) -> 9GB'; then
  pass_part "Parte 2.3 (resumen y minimo)" 0.75
else
  reasons=()
  if [[ ! -f "$revision_file" ]]; then
    alt_revision="$(list_matching_files "$root_dir/resultados" 'revision*')"
    if [[ -n "$alt_revision" ]]; then
      reasons+=("falta resultados/revision_20.txt; ficheros parecidos encontrados: $alt_revision")
    else
      reasons+=("falta resultados/revision_20.txt")
    fi
  fi
  if [[ -f "$revision_file" ]] && ! has_fixed "$revision_file" 'Resumen: 5 validos, 0 formato, 2 datos, 3 disco, 2 ram, 2 no_operativo'; then
    resumen_actual="$(extract_matching_lines "$revision_file" '^Resumen:' 2)"
    if [[ -n "$resumen_actual" ]]; then
      reasons+=("el resumen final no coincide con la solucion; actual: $resumen_actual")
    else
      reasons+=("no aparece el resumen final esperado")
    fi
  fi
  if [[ -f "$revision_file" ]] && ! has_fixed "$revision_file" 'Minimo disco: bk01 (10.0.0.25) -> 9GB'; then
    minimo_actual="$(extract_matching_lines "$revision_file" '^Minimo disco:' 2)"
    if [[ -n "$minimo_actual" ]]; then
      reasons+=("el minimo de disco no coincide con la solucion; actual: $minimo_actual")
    else
      reasons+=("no aparece el minimo de disco esperado")
    fi
  fi
  fail_part "Parte 2.3 (resumen y minimo)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$revision_file" ]] \
  && has_fixed "$revision_file" 'ERROR DATOS: cache01 (10.0.0.24)' \
  && has_fixed "$revision_file" 'ERROR DATOS: mon01 (10.0.0.27)'; then
  pass_part "Parte 2.4 (errores de datos)" 0.75
else
  reasons=()
  if [[ ! -f "$revision_file" ]]; then
    alt_revision="$(list_matching_files "$root_dir/resultados" 'revision*')"
    if [[ -n "$alt_revision" ]]; then
      reasons+=("falta resultados/revision_20.txt; ficheros parecidos encontrados: $alt_revision")
    else
      reasons+=("falta resultados/revision_20.txt")
    fi
  fi
  { [[ -f "$revision_file" ]] && has_fixed "$revision_file" 'ERROR DATOS: cache01 (10.0.0.24)'; } || reasons+=("no se detecta el error de datos de cache01")
  { [[ -f "$revision_file" ]] && has_fixed "$revision_file" 'ERROR DATOS: mon01 (10.0.0.27)'; } || reasons+=("no se detecta el error de datos de mon01")
  if [[ -f "$revision_file" ]]; then
    errores_actuales="$(extract_matching_lines "$revision_file" '^ERROR DATOS:' 5)"
    [[ -n "$errores_actuales" ]] && reasons+=("errores de datos presentes en la salida: $errores_actuales")
  fi
  fail_part "Parte 2.4 (errores de datos)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$revision_file" ]] \
  && has_fixed "$revision_file" 'DISCO BAJO: web01 (10.0.0.21) -> 12GB' \
  && has_fixed "$revision_file" 'RAM BAJA: app01 (10.0.0.22) -> 2GB' \
  && has_fixed "$revision_file" 'SERVICIO NO OPERATIVO: bk01 -> caido'; then
  pass_part "Parte 2.5 (alertas y servicio)" 0.75
else
  reasons=()
  if [[ ! -f "$revision_file" ]]; then
    alt_revision="$(list_matching_files "$root_dir/resultados" 'revision*')"
    if [[ -n "$alt_revision" ]]; then
      reasons+=("falta resultados/revision_20.txt; ficheros parecidos encontrados: $alt_revision")
    else
      reasons+=("falta resultados/revision_20.txt")
    fi
  fi
  { [[ -f "$revision_file" ]] && has_fixed "$revision_file" 'DISCO BAJO: web01 (10.0.0.21) -> 12GB'; } || reasons+=("no aparece la alerta de disco de web01")
  { [[ -f "$revision_file" ]] && has_fixed "$revision_file" 'RAM BAJA: app01 (10.0.0.22) -> 2GB'; } || reasons+=("no aparece la alerta de RAM de app01")
  { [[ -f "$revision_file" ]] && has_fixed "$revision_file" 'SERVICIO NO OPERATIVO: bk01 -> caido'; } || reasons+=("no aparece la alerta de servicio no operativo de bk01")
  if [[ -f "$revision_file" ]]; then
    alertas_actuales="$(extract_matching_lines "$revision_file" '^(DISCO BAJO|RAM BAJA|SERVICIO NO OPERATIVO):' 12)"
    [[ -n "$alertas_actuales" ]] && reasons+=("alertas presentes en la salida: $alertas_actuales")
  fi
  fail_part "Parte 2.5 (alertas y servicio)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$script_file" ]] \
  && has_regex "$script_file" '\bwhile\b' \
  && has_regex "$script_file" '\bif\b'; then
  pass_part "Parte 2.6 (estructuras de control)" 0.50
else
  reasons=()
  [[ -f "$script_file" ]] || reasons+=("falta scripts/revision_inventario.sh")
  { [[ -f "$script_file" ]] && has_regex "$script_file" '\bwhile\b'; } || reasons+=("no se detecta uso de while")
  { [[ -f "$script_file" ]] && has_regex "$script_file" '\bif\b'; } || reasons+=("no se detecta uso de if")
  fail_part "Parte 2.6 (estructuras de control)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$csv_file" ]] \
  && has_fixed "$csv_file" 'ip,nombre,disco,ram,servicio,tipo,estado' \
  && has_fixed "$csv_file" '10.0.0.23,db01,40,8,mariadb,datos,activo' \
  && has_fixed "$csv_file" '10.0.0.25,bk01,9,1,rsync,copias,caido'; then
  pass_part "Parte 2.7 (CSV)" 0.50
else
  reasons=()
  if [[ ! -f "$csv_file" ]]; then
    alt_csv="$(list_matching_files "$root_dir/resultados" '*.csv')"
    if [[ -n "$alt_csv" ]]; then
      reasons+=("falta resultados/resumen_inventario.csv; CSV presentes: $alt_csv")
    else
      reasons+=("falta resultados/resumen_inventario.csv")
    fi
  fi
  if [[ -f "$csv_file" ]] && ! has_fixed "$csv_file" 'ip,nombre,disco,ram,servicio,tipo,estado'; then
    reasons+=("la cabecera del CSV no coincide con la pedida; cabecera actual: $(first_line "$csv_file")")
  fi
  { [[ -f "$csv_file" ]] && has_fixed "$csv_file" '10.0.0.23,db01,40,8,mariadb,datos,activo'; } || reasons+=("no aparece la fila esperada de db01 en el CSV")
  { [[ -f "$csv_file" ]] && has_fixed "$csv_file" '10.0.0.25,bk01,9,1,rsync,copias,caido'; } || reasons+=("no aparece la fila esperada de bk01 en el CSV")
  fail_part "Parte 2.7 (CSV)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$script_copy_file" && -s "$script_copy_file" ]]; then
  pass_part "Parte 2.8 (copia del script)" 0.50
else
  reasons=()
  if [[ ! -f "$script_copy_file" ]]; then
    alt_script_copy="$(list_matching_files "$root_dir/resultados" '*script*')"
    [[ -z "$alt_script_copy" ]] && alt_script_copy="$(list_matching_files "$root_dir/resultados" 'revision*')"
    if [[ -n "$alt_script_copy" ]]; then
      reasons+=("falta resultados/revision_script.txt; ficheros parecidos encontrados: $alt_script_copy")
    else
      reasons+=("falta resultados/revision_script.txt")
    fi
  fi
  [[ -f "$script_copy_file" && -s "$script_copy_file" ]] || reasons+=("revision_script.txt esta vacio")
  fail_part "Parte 2.8 (copia del script)" "$(join_messages "${reasons[@]}")"
fi

servicios_file="$root_dir/resultados/servicios.txt"
if [[ -f "$servicios_file" ]] \
  && has_regex "$servicios_file" 'upgradable|packages can be upgraded' \
  && has_regex "$servicios_file" 'nginx' \
  && has_regex "$servicios_file" 'curl'; then
  pass_part "Parte 3.1 (actualizacion e instalacion)" 0.50
else
  reasons=()
  [[ -f "$servicios_file" ]] || reasons+=("falta resultados/servicios.txt")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" 'upgradable|packages can be upgraded'; } || reasons+=("no hay evidencia de actualizacion o de paquetes actualizables")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" 'nginx'; } || reasons+=("no hay evidencia suficiente de nginx")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" 'curl'; } || reasons+=("no hay evidencia suficiente de curl")
  fail_part "Parte 3.1 (actualizacion e instalacion)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$servicios_file" ]] && has_fixed "$servicios_file" 'Ordinario UD1 UD2'; then
  pass_part "Parte 3.2 (web personalizada)" 0.50
else
  reasons=()
  [[ -f "$servicios_file" ]] || reasons+=("falta resultados/servicios.txt")
  { [[ -f "$servicios_file" ]] && has_fixed "$servicios_file" 'Ordinario UD1 UD2'; } || reasons+=("no se detecta el texto 'Ordinario UD1 UD2' en la evidencia de la web")
  if [[ -f "$servicios_file" ]]; then
    web_actual="$(extract_matching_lines "$servicios_file" 'Ordinario|ord-ud1ud2|<h1>|<p>|127\.0\.0\.1' 8)"
    [[ -n "$web_actual" ]] && reasons+=("fragmentos web encontrados en la evidencia: $web_actual")
  fi
  fail_part "Parte 3.2 (web personalizada)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$servicios_file" ]] \
  && has_regex "$servicios_file" 'Depends:' \
  && has_regex "$servicios_file" '/usr|/etc|/lib/systemd/system/nginx'; then
  pass_part "Parte 3.3 (consulta de paquetes)" 0.50
else
  reasons=()
  [[ -f "$servicios_file" ]] || reasons+=("falta resultados/servicios.txt")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" 'Depends:'; } || reasons+=("no aparece informacion de dependencias de nginx")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" '/usr|/etc|/lib/systemd/system/nginx'; } || reasons+=("no aparece un listado de ficheros relevantes del paquete nginx")
  if [[ -f "$servicios_file" ]]; then
    paquete_actual="$(extract_matching_lines "$servicios_file" 'Depends:|Package: nginx|/etc/|/usr/' 8)"
    [[ -n "$paquete_actual" ]] && reasons+=("fragmentos de paqueteria encontrados: $paquete_actual")
  fi
  fail_part "Parte 3.3 (consulta de paquetes)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$servicios_file" ]] \
  && has_regex "$servicios_file" 'nginx\.service|Active:' \
  && has_regex "$servicios_file" 'LISTEN|:80' \
  && has_regex "$servicios_file" 'disabled|enabled' \
  && has_regex "$servicios_file" '\bcron\b'; then
  pass_part "Parte 3.4 (servicio, logs y red)" 0.50
else
  reasons=()
  [[ -f "$servicios_file" ]] || reasons+=("falta resultados/servicios.txt")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" 'nginx\.service|Active:'; } || reasons+=("no hay evidencia clara del estado de nginx")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" 'LISTEN|:80'; } || reasons+=("no hay evidencia de escucha en red o del puerto 80")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" 'disabled|enabled'; } || reasons+=("no hay evidencia del estado de habilitacion de nginx")
  { [[ -f "$servicios_file" ]] && has_regex "$servicios_file" '\bcron\b'; } || reasons+=("no hay evidencia del estado de la unidad cron")
  if [[ -f "$servicios_file" ]]; then
    servicio_actual="$(extract_matching_lines "$servicios_file" 'nginx\.service|Active:|LISTEN|:80|disabled|enabled|cron|http://127\.0\.0\.1' 10)"
    [[ -n "$servicio_actual" ]] && reasons+=("fragmentos de servicio y red encontrados: $servicio_actual")
  fi
  fail_part "Parte 3.4 (servicio, logs y red)" "$(join_messages "${reasons[@]}")"
fi

procesos_file="$root_dir/resultados/procesos.txt"
crontab_file="$root_dir/cron/crontab.txt"
cron_fechas_ok=false
cron_carga_ok=false

if [[ -f "$crontab_file" ]]; then
  if has_regex "$crontab_file" '^\*/15 \* \* \* \* (/usr/bin/)?date >> (\$HOME|~)/ordinario_ud1_ud2/cron/fechas\.log$' \
    || has_regex "$crontab_file" '^\*/15 \* \* \* \* (/usr/bin/)?date >> /[^$[:space:]][^[:space:]]*/ordinario_ud1_ud2/cron/fechas\.log$'; then
    cron_fechas_ok=true
  fi

  if has_regex "$crontab_file" '^5 \* \* \* \* (/usr/bin/)?uptime >> (\$HOME|~)/ordinario_ud1_ud2/cron/carga\.log$' \
    || has_regex "$crontab_file" '^5 \* \* \* \* (/usr/bin/)?uptime >> /[^$[:space:]][^[:space:]]*/ordinario_ud1_ud2/cron/carga\.log$'; then
    cron_carga_ok=true
  fi
fi

if [[ -f "$procesos_file" ]] \
  && has_fixed "$procesos_file" 'sleep 600' \
  && has_fixed "$procesos_file" 'sleep 900' \
  && has_regex "$procesos_file" 'renice| NI ' \
  && has_regex "$procesos_file" 'SIGTERM|TERM|kill -TERM' \
  && has_regex "$procesos_file" 'SIGKILL|KILL|kill -KILL'; then
  pass_part "Parte 4.1 (procesos y senales)" 0.50
else
  reasons=()
  [[ -f "$procesos_file" ]] || reasons+=("falta resultados/procesos.txt")
  { [[ -f "$procesos_file" ]] && has_fixed "$procesos_file" 'sleep 600'; } || reasons+=("no aparece evidencia de sleep 600")
  { [[ -f "$procesos_file" ]] && has_fixed "$procesos_file" 'sleep 900'; } || reasons+=("no aparece evidencia de sleep 900")
  { [[ -f "$procesos_file" ]] && has_regex "$procesos_file" 'renice| NI '; } || reasons+=("no hay evidencia del cambio de prioridad o niceness")
  { [[ -f "$procesos_file" ]] && has_regex "$procesos_file" 'SIGTERM|TERM|kill -TERM'; } || reasons+=("no hay evidencia del SIGTERM sobre sleep 900")
  { [[ -f "$procesos_file" ]] && has_regex "$procesos_file" 'SIGKILL|KILL|kill -KILL'; } || reasons+=("no hay evidencia del SIGKILL sobre sleep 600")
  if [[ -f "$procesos_file" ]]; then
    procesos_actuales="$(extract_matching_lines "$procesos_file" 'sleep 600|sleep 900|renice|SIGTERM|SIGKILL|kill -l' 10)"
    [[ -n "$procesos_actuales" ]] && reasons+=("fragmentos de procesos encontrados: $procesos_actuales")
  fi
  fail_part "Parte 4.1 (procesos y senales)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$crontab_file" ]] \
  && [[ "$cron_fechas_ok" == true ]] \
  && [[ "$cron_carga_ok" == true ]]; then
  pass_part "Parte 4.2 (cron)" 0.50
else
  reasons=()
  if [[ ! -f "$crontab_file" ]]; then
    alt_cron="$(list_matching_files "$root_dir/cron" '*cron*')"
    if [[ -n "$alt_cron" ]]; then
      reasons+=("falta cron/crontab.txt; ficheros parecidos encontrados: $alt_cron")
    else
      reasons+=("falta cron/crontab.txt")
    fi
  fi
  [[ "$cron_fechas_ok" == true ]] || reasons+=("no aparece la tarea exacta cada 15 minutos para fechas.log")
  [[ "$cron_carga_ok" == true ]] || reasons+=("no aparece la tarea exacta de uptime al minuto 5 para carga.log")
  if [[ -f "$crontab_file" ]]; then
    cron_actual="$(extract_matching_lines "$crontab_file" '^\*/15 |^5 |ordinario_ud1_ud2/cron|date|uptime' 10)"
    [[ -n "$cron_actual" ]] && reasons+=("lineas reales del crontab: $cron_actual")
  fi
  fail_part "Parte 4.2 (cron)" "$(join_messages "${reasons[@]}")"
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
  reasons=()
  [[ -f "$estado_service" ]] || reasons+=("falta cron/estado.service")
  [[ -f "$estado_timer" ]] || reasons+=("falta cron/estado.timer")
  { [[ -f "$estado_service" ]] && has_fixed "$estado_service" 'estado.log'; } || reasons+=("estado.service no referencia estado.log")
  { [[ -f "$estado_service" ]] && has_fixed "$estado_service" 'date'; } || reasons+=("estado.service no incluye date")
  { [[ -f "$estado_service" ]] && has_fixed "$estado_service" 'uptime'; } || reasons+=("estado.service no incluye uptime")
  { [[ -f "$estado_timer" ]] && has_fixed "$estado_timer" 'OnCalendar='; } || reasons+=("estado.timer no define OnCalendar")
  { [[ -f "$estado_timer" ]] && has_fixed "$estado_timer" 'Persistent=true'; } || reasons+=("estado.timer no define Persistent=true")
  if [[ -f "$estado_service" ]]; then
    service_actual="$(extract_matching_lines "$estado_service" 'ExecStart|Type=|estado\.log|date|uptime' 8)"
    [[ -n "$service_actual" ]] && reasons+=("contenido actual de estado.service: $service_actual")
  fi
  if [[ -f "$estado_timer" ]]; then
    timer_actual="$(extract_matching_lines "$estado_timer" 'OnCalendar|Persistent|WantedBy' 8)"
    [[ -n "$timer_actual" ]] && reasons+=("contenido actual de estado.timer: $timer_actual")
  fi
  fail_part "Parte 5.1 (service y timer)" "$(join_messages "${reasons[@]}")"
fi

if [[ -f "$timer_file" ]] \
  && has_fixed "$timer_file" 'estado.timer' \
  && has_fixed "$timer_file" 'estado.service'; then
  pass_part "Parte 5.2 (evidencias del timer)" 0.50
else
  reasons=()
  [[ -f "$timer_file" ]] || reasons+=("falta resultados/timer.txt")
  { [[ -f "$timer_file" ]] && has_fixed "$timer_file" 'estado.timer'; } || reasons+=("timer.txt no muestra evidencia de estado.timer")
  { [[ -f "$timer_file" ]] && has_fixed "$timer_file" 'estado.service'; } || reasons+=("timer.txt no muestra evidencia de estado.service")
  if [[ -f "$timer_file" ]]; then
    timer_evidencia="$(extract_matching_lines "$timer_file" 'estado\.timer|estado\.service|NEXT|Trigger|list-timers|journalctl' 10)"
    [[ -n "$timer_evidencia" ]] && reasons+=("fragmentos de evidencia del timer: $timer_evidencia")
  fi
  fail_part "Parte 5.2 (evidencias del timer)" "$(join_messages "${reasons[@]}")"
fi

echo "Puntuacion: $score/$max"
