#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: corrige_entregas.sh <directorio_alumnado> [--csv salida.csv]

Cada alumno debe estar en un subdirectorio y contener un fichero .tar.gz con
la entrega.
EOF
}

ALUMNOS_DIR=""
CSV_PATH=""
declare -a CRITERIA=(
  "p1_1|Parte 1.1 (contenedor y arranque)|0.25|parte_1"
  "p1_2|Parte 1.2 (memoria y autostart)|0.25|parte_1"
  "p1_3|Parte 1.3 (estructura y evidencias)|0.25|parte_1"
  "p1_4|Parte 1.4 (snapshot)|0.25|parte_1"
  "p2_1|Parte 2.1 (inventario)|0.50|parte_2"
  "p2_2|Parte 2.2 (script y permisos)|0.75|parte_2"
  "p2_3|Parte 2.3 (resumen y minimo)|0.75|parte_2"
  "p2_4|Parte 2.4 (errores de datos)|0.75|parte_2"
  "p2_5|Parte 2.5 (alertas y servicio)|0.75|parte_2"
  "p2_6|Parte 2.6 (estructuras de control)|0.50|parte_2"
  "p2_7|Parte 2.7 (CSV)|0.50|parte_2"
  "p2_8|Parte 2.8 (copia del script)|0.50|parte_2"
  "p3_1|Parte 3.1 (actualizacion e instalacion)|0.50|parte_3"
  "p3_2|Parte 3.2 (web personalizada)|0.50|parte_3"
  "p3_3|Parte 3.3 (consulta de paquetes)|0.50|parte_3"
  "p3_4|Parte 3.4 (servicio, logs y red)|0.50|parte_3"
  "p4_1|Parte 4.1 (procesos y senales)|0.50|parte_4"
  "p4_2|Parte 4.2 (cron)|0.50|parte_4"
  "p5_1|Parte 5.1 (service y timer)|0.50|parte_5"
  "p5_2|Parte 5.2 (evidencias del timer)|0.50|parte_5"
)
declare -A CRITERIA_LABELS=()
declare -A CRITERIA_PARTS=()
declare -a CRITERIA_KEYS=()

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
      if [[ -z "$ALUMNOS_DIR" ]]; then
        ALUMNOS_DIR="$1"
        shift
      else
        echo "Argumento inesperado: $1" >&2
        exit 1
      fi
      ;;
  esac
done

[[ -n "$ALUMNOS_DIR" ]] || { usage >&2; exit 1; }
[[ -d "$ALUMNOS_DIR" ]] || { echo "No existe el directorio $ALUMNOS_DIR" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/check_entrega.sh"

csv_escape() {
  local value="${1//$'\n'/ | }"
  value="${value//\"/\"\"}"
  printf '"%s"' "$value"
}

format_score() {
  awk -v n="${1:-0}" 'BEGIN { printf "%.2f", n + 0 }'
}

sum_scores() {
  awk -v a="${1:-0}" -v b="${2:-0}" 'BEGIN { printf "%.2f", a + b }'
}

join_observaciones() {
  local joined=""
  local item
  for item in "$@"; do
    if [[ -n "$joined" ]]; then
      joined+="; "
    fi
    joined+="$item"
  done
  printf '%s' "$joined"
}

if [[ ! -x "$CHECK_SCRIPT" ]]; then
  chmod u+x "$CHECK_SCRIPT" 2>/dev/null || true
fi

for criterion in "${CRITERIA[@]}"; do
  IFS='|' read -r key label _ part_key <<< "$criterion"
  CRITERIA_KEYS+=("$key")
  CRITERIA_LABELS["$key"]="$label"
  CRITERIA_PARTS["$key"]="$part_key"
done

if [[ -n "$CSV_PATH" ]]; then
  {
    printf 'alumno,id,nota_global,parte_1,parte_2,parte_3,parte_4,parte_5'
    for key in "${CRITERIA_KEYS[@]}"; do
      printf ',%s' "$key"
    done
    printf ',observaciones\n'
  } > "$CSV_PATH"
fi

for alumno_dir in "$ALUMNOS_DIR"/*; do
  [[ -d "$alumno_dir" ]] || continue
  declare -A criterion_scores=()
  declare -A part_scores=(
    [parte_1]="0.00"
    [parte_2]="0.00"
    [parte_3]="0.00"
    [parte_4]="0.00"
    [parte_5]="0.00"
  )
  alumno_raw="$(basename "$alumno_dir")"
  alumno="$alumno_raw"
  alumno_id=""
  if [[ "$alumno_raw" =~ ^(.+)_([0-9]+)_assignsubmission_file$ ]]; then
    alumno="${BASH_REMATCH[1]}"
    alumno_id="${BASH_REMATCH[2]}"
  fi

  tarball="$(find "$alumno_dir" -maxdepth 1 -type f \( -name '*.tar.gz' -o -name '*.tar' \) | head -n1 || true)"

  if [[ -z "$tarball" ]]; then
    echo "$alumno -> SIN ENTREGA"
    if [[ -n "$CSV_PATH" ]]; then
      {
        printf '%s,%s,0.00,0.00,0.00,0.00,0.00,0.00' \
        "$(csv_escape "$alumno")" \
        "$(csv_escape "$alumno_id")"
        for key in "${CRITERIA_KEYS[@]}"; do
          printf ',0.00'
        done
        printf ',%s\n' "$(csv_escape "SIN ENTREGA")"
      } >> "$CSV_PATH"
    fi
    continue
  fi

  observaciones=()
  tarball_name="$(basename "$tarball")"
  tarball_type="$(file -b "$tarball")"
  if [[ "$tarball_name" != "ordinario_ud1_ud2_entrega.tar.gz" ]]; then
    observaciones+=("nombre de entrega distinto: $tarball_name")
  fi
  if [[ "$tarball_type" == *"POSIX tar archive"* ]]; then
    observaciones+=("archivo tar sin compresion gzip")
  fi

  if output="$("$CHECK_SCRIPT" "$tarball" 2>&1)"; then
    score="0.00"
    while IFS= read -r line; do
      if [[ "$line" =~ ^\[(OK|NO)\]\ (.+)\ \(\+([0-9.]+)\)(\ \-\>\ (.*))?$ ]]; then
        status="${BASH_REMATCH[1]}"
        label="${BASH_REMATCH[2]}"
        pts="${BASH_REMATCH[3]}"
        detail="${BASH_REMATCH[5]:-}"
        awarded="0.00"

        for key in "${CRITERIA_KEYS[@]}"; do
          if [[ "${CRITERIA_LABELS[$key]}" == "$label" ]]; then
            if [[ "$status" == "OK" ]]; then
              awarded="$(format_score "$pts")"
            else
              if [[ -n "$detail" ]]; then
                observaciones+=("$label: $detail")
              else
                observaciones+=("$label")
              fi
            fi
            criterion_scores["$key"]="$awarded"
            part_key="${CRITERIA_PARTS[$key]}"
            part_scores["$part_key"]="$(sum_scores "${part_scores[$part_key]}" "$awarded")"
            break
          fi
        done
      elif [[ "$line" =~ ^Puntuacion:\ ([0-9.]+)/10$ ]]; then
        score="$(format_score "${BASH_REMATCH[1]}")"
      fi
    done <<< "$output"
  else
    score="0.00"
    observaciones+=("error al corregir: $(tr '\n' ' ' <<<"$output" | sed 's/  */ /g; s/ $//')")
  fi

  if [[ ${#observaciones[@]} -eq 0 ]]; then
    observacion_texto="OK"
  else
    observacion_texto="$(join_observaciones "${observaciones[@]}")"
  fi

  echo "$alumno -> $score/10"
  if [[ -n "$CSV_PATH" ]]; then
    {
      printf '%s,%s,%s,%s,%s,%s,%s,%s' \
        "$(csv_escape "$alumno")" \
        "$(csv_escape "$alumno_id")" \
        "$score" \
        "${part_scores[parte_1]}" \
        "${part_scores[parte_2]}" \
        "${part_scores[parte_3]}" \
        "${part_scores[parte_4]}" \
        "${part_scores[parte_5]}"
      for key in "${CRITERIA_KEYS[@]}"; do
        printf ',%s' "$(format_score "${criterion_scores[$key]:-0}")"
      done
      printf ',%s\n' "$(csv_escape "$observacion_texto")"
    } >> "$CSV_PATH"
  fi
done
