#!/usr/bin/env bash
# Herramienta rápida para autocorregir el examen de shell scripting.

set -euo pipefail
export LC_ALL=C

usage() {
  cat <<'EOF'
Uso: corregir_examen_shell.sh <directorio_entregas> [--csv salida.csv]

Cada entrega debe estar en un subdirectorio (por ejemplo, entregas/alumno01)
que incluya los scripts doble.sh, inventario_usuarios.sh y alertas_equipos.sh.
El script ejecuta pruebas básicas y genera puntuaciones parciales.
EOF
}

join_by() {
  local IFS="$1"
  shift || return 0
  printf "%s" "$*"
}

add_points() {
  local var_name=$1
  local inc=$2
  local current="${!var_name:-0}"
  local result
  result=$(awk -v a="$current" -v b="$inc" 'BEGIN {printf "%.2f", a + b}')
  printf -v "$var_name" "%s" "$result"
}

SUBMISSIONS=""
CSV_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --csv)
      [[ $# -ge 2 ]] || { echo "Falta la ruta para --csv" >&2; exit 1; }
      CSV_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -z $SUBMISSIONS ]]; then
        SUBMISSIONS="$1"
        shift
      else
        echo "Argumento inesperado: $1" >&2
        exit 1
      fi
      ;;
  esac
done

[[ -n $SUBMISSIONS ]] || { usage >&2; exit 1; }
[[ -d $SUBMISSIONS ]] || { echo "No existe el directorio $SUBMISSIONS" >&2; exit 1; }

if [[ -n $CSV_PATH ]]; then
  echo "alumno,ej1,ej2,ej3,total,observaciones" > "$CSV_PATH"
fi

declare workdir=""

cleanup() {
  if [[ -n $workdir && -d $workdir ]]; then
    rm -rf "$workdir"
  fi
  return 0
}

trap cleanup EXIT

declare -a feedback_doble feedback_inventario feedback_alertas all_feedback
score_doble=0 score_inventario=0 score_alertas=0

run_doble_tests() {
  local script_path=$1
  score_doble=0
  feedback_doble=()

  if [[ ! -f $script_path ]]; then
    feedback_doble+=("doble.sh no encontrado")
    return
  fi

  if [[ ! -x $script_path ]]; then
    feedback_doble+=("doble.sh sin permisos de ejecución (se lanzó con bash)")
  fi

  local ok_input=4.5
  local expected
  expected=$(awk -v v="$ok_input" 'BEGIN {printf "%.4f", v*2}')

  local output
  if output=$(bash "$script_path" "$ok_input" 2>&1); then
    local numeric
    numeric=$(grep -Eo '[-+]?[0-9]+([.][0-9]+)?' <<<"$output" | tail -n1 || true)
    if [[ -n $numeric ]]; then
      local diff
      diff=$(awk -v a="$numeric" -v b="$expected" 'BEGIN {d=a-b; if (d<0) d*=-1; printf "%.4f", d}')
      if awk -v d="$diff" 'BEGIN {exit !(d <= 0.01)}'; then
        add_points score_doble 0.5
      else
        feedback_doble+=("doble.sh no muestra el resultado esperado para $ok_input (obtuvo $numeric)")
      fi
    else
      feedback_doble+=("doble.sh no muestra ningún número reconocible")
    fi
  else
    feedback_doble+=("doble.sh falla con un argumento válido ($ok_input)")
  fi

  if bash "$script_path" "texto" >/dev/null 2>&1; then
    feedback_doble+=("doble.sh debería rechazar argumentos no numéricos")
  else
    add_points score_doble 0.5
  fi
}

run_inventario_tests() {
  local script_path=$1
  local usuarios_ok=$2
  local usuarios_mix=$3

  score_inventario=0
  feedback_inventario=()

  if [[ ! -f $script_path ]]; then
    feedback_inventario+=("inventario_usuarios.sh no encontrado")
    return
  fi

  add_points score_inventario 0.25

  if [[ -x $script_path ]]; then
    add_points score_inventario 0.25
  else
    feedback_inventario+=("inventario_usuarios.sh no tiene permiso de ejecución")
  fi

  local output status
  output=$(bash "$script_path" "$usuarios_ok" 2>&1)
  status=$?
  if [[ $status -eq 0 ]]; then
    add_points score_inventario 1.0
    if grep -Eq '^Usuario[[:space:]]+UID[[:space:]]+Num\.Grupos[[:space:]]+Grupos$' <<<"$output"; then
      add_points score_inventario 0.75
    else
      feedback_inventario+=("La cabecera debe incluir Usuario, UID, NumGrupos y Grupos en ese orden")
    fi
    if grep -Eq '^root[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+.+$' <<<"$output"; then
      add_points score_inventario 0.75
    else
      feedback_inventario+=("No aparece la fila esperada para root con UID y grupos")
    fi
    if grep -Eq '^daemon[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+.+$' <<<"$output"; then
      add_points score_inventario 0.75
    else
      feedback_inventario+=("No aparece la fila esperada para daemon con el formato correcto")
    fi
    local data_rows
    data_rows=$(grep -E '^[[:alnum:]_.-]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+' <<<"$output" | wc -l | tr -d ' ')
    if [[ $data_rows -ge 2 ]]; then
      add_points score_inventario 0.75
    else
      feedback_inventario+=("La tabla debería incluir al menos dos filas de datos (root y daemon)")
    fi
  else
    feedback_inventario+=("inventario_usuarios.sh falla con un fichero válido ($usuarios_ok)")
  fi

  if bash "$script_path" "$usuarios_ok.noexiste" >/dev/null 2>&1; then
    feedback_inventario+=("inventario_usuarios.sh debería detectar ficheros inexistentes")
  else
    add_points score_inventario 0.25
  fi

  output=$(bash "$script_path" "$usuarios_mix" 2>&1)
  status=$?
  if [[ $status -ne 0 ]]; then
    add_points score_inventario 0.15
    if grep -Eq 'AVISO:.*no existe' <<<"$output"; then
      add_points score_inventario 0.10
    else
      feedback_inventario+=("Cuando un usuario falta debe avisar con 'AVISO: <usuario> no existe'")
    fi
  else
    feedback_inventario+=("inventario_usuarios.sh debería devolver código 1 si algún usuario no existe")
  fi
}

run_alertas_tests() {
  local script_path=$1
  local equipos_sample=$2

  score_alertas=0
  feedback_alertas=()

  if [[ ! -f $script_path ]]; then
    feedback_alertas+=("alertas_equipos.sh no encontrado")
    return
  fi

  add_points score_alertas 0.25

  if [[ -x $script_path ]]; then
    add_points score_alertas 0.25
  else
    feedback_alertas+=("alertas_equipos.sh sin permiso de ejecución")
  fi

  local script_dir
  script_dir=$(dirname "$script_path")
  local script_name
  script_name=$(basename "$script_path")

  pushd "$script_dir" >/dev/null

  local backup=""
  if [[ -f equipos.txt ]]; then
    backup=$(mktemp)
    cp equipos.txt "$backup"
  fi
  cp "$equipos_sample" equipos.txt

  local output
  if output=$(bash "./$script_name" 40 2>&1); then
    if grep -q "srv01" <<<"$output" && grep -q "srv03" <<<"$output"; then
      add_points score_alertas 0.75
    else
      feedback_alertas+=("alertas_equipos.sh no genera alertas para los equipos esperados")
    fi
    local resumen
    resumen=$(grep -E "Resumen:" <<<"$output" | tail -n1 || true)
    if [[ $resumen =~ ([0-9]+) ]]; then
      local total="${BASH_REMATCH[1]}"
      if [[ $total -eq 2 ]]; then
        add_points score_alertas 1.25
      else
        feedback_alertas+=("Resumen indica $total alertas y se esperaban 2")
      fi
    else
      feedback_alertas+=("alertas_equipos.sh no muestra el resumen final")
    fi
  else
    feedback_alertas+=("alertas_equipos.sh falla con datos correctos")
  fi

  if bash "./$script_name" foo >/dev/null 2>&1; then
    feedback_alertas+=("alertas_equipos.sh debería rechazar umbrales no enteros")
  else
    add_points score_alertas 0.5
  fi

  if output=$(bash "./$script_name" 10 2>&1); then
    if grep -q "Resumen: 0" <<<"$output"; then
      add_points score_alertas 0.5
    else
      feedback_alertas+=("Con umbral 10 debería indicar 0 alertas")
    fi
  fi

  rm -f equipos.tmp 2>/dev/null || true
  if mv equipos.txt equipos.tmp 2>/dev/null; then
    if bash "./$script_name" 40 >/dev/null 2>&1; then
      feedback_alertas+=("alertas_equipos.sh debería fallar si falta equipos.txt")
    else
      add_points score_alertas 0.5
    fi
    mv equipos.tmp equipos.txt
  fi

  rm -f equipos.txt
  if [[ -n $backup ]]; then
    mv "$backup" equipos.txt
  fi

  popd >/dev/null
}

mapfile -t STUDENT_DIRS < <(find "$SUBMISSIONS" -mindepth 1 -maxdepth 1 -type d | sort)

[[ ${#STUDENT_DIRS[@]} -gt 0 ]] || { echo "No se encontraron subdirectorios en $SUBMISSIONS" >&2; exit 1; }

printf "%-25s %5s %5s %5s %6s  %s\n" "Alumno" "E1/1" "E2/5" "E3/4" "Total" "Observaciones"
printf "%-25s %5s %5s %5s %6s  %s\n" "-------------------------" "-----" "-----" "-----" "------" "-----------------------------"

for dir in "${STUDENT_DIRS[@]}"; do
  workdir=$(mktemp -d)
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$dir"/ "$workdir"/ >/dev/null
  else
    cp -R "$dir"/. "$workdir"/
  fi

  local_usuarios_ok="$workdir/usuarios_ok.txt"
  local_usuarios_mix="$workdir/usuarios_mix.txt"
  cat > "$local_usuarios_ok" <<'EOF'
# fichero de prueba
root

daemon
EOF

  cat > "$local_usuarios_mix" <<'EOF'
root
usuario_inexistente__aso
EOF

  local_equipos="$workdir/equipos_muestra.txt"
  cat > "$local_equipos" <<'EOF'
10.0.0.5 srv01 20 8
10.0.0.6 srv02 80 16
10.0.0.7 srv03 35 32
EOF

  run_doble_tests "$workdir/doble.sh"
  run_inventario_tests "$workdir/inventario_usuarios.sh" "$local_usuarios_ok" "$local_usuarios_mix"
  run_alertas_tests "$workdir/alertas_equipos.sh" "$local_equipos"

  total=$(awk -v a="$score_doble" -v b="$score_inventario" -v c="$score_alertas" 'BEGIN {printf "%.2f", a + b + c}')

  all_feedback=()
  [[ ${#feedback_doble[@]} -gt 0 ]] && all_feedback+=("E1: $(join_by ', ' "${feedback_doble[@]}")")
  [[ ${#feedback_inventario[@]} -gt 0 ]] && all_feedback+=("E2: $(join_by ', ' "${feedback_inventario[@]}")")
  [[ ${#feedback_alertas[@]} -gt 0 ]] && all_feedback+=("E3: $(join_by ', ' "${feedback_alertas[@]}")")
  observations=""
  if [[ ${#all_feedback[@]} -gt 0 ]]; then
    observations=$(join_by " | " "${all_feedback[@]}")
  else
    observations="OK"
  fi

  student=$(basename "$dir")
  printf "%-25s %5.2f %5.2f %5.2f %6.2f  %s\n" "$student" "$score_doble" "$score_inventario" "$score_alertas" "$total" "$observations"

  if [[ -n $CSV_PATH ]]; then
    printf "%s,%.2f,%.2f,%.2f,%.2f,\"%s\"\n" "$student" "$score_doble" "$score_inventario" "$score_alertas" "$total" "$observations" >> "$CSV_PATH"
  fi

  rm -rf "$workdir"
  workdir=""
done
