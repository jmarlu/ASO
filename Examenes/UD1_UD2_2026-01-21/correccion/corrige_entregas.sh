#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: corrige_entregas.sh <directorio_alumnos> [--csv salida.csv]

Cada alumno debe estar en un subdirectorio (por ejemplo, alumnos/ana, alumnos/pedro)
y contener un fichero .tar.gz con la entrega.
EOF
}

ALUMNOS_DIR=""
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
      if [[ -z $ALUMNOS_DIR ]]; then
        ALUMNOS_DIR="$1"
        shift
      else
        echo "Argumento inesperado: $1" >&2
        exit 1
      fi
      ;;
  esac
done

[[ -n $ALUMNOS_DIR ]] || { usage >&2; exit 1; }
[[ -d $ALUMNOS_DIR ]] || { echo "No existe el directorio $ALUMNOS_DIR" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/check_entrega.sh"

if [[ ! -x "$CHECK_SCRIPT" ]]; then
  chmod u+x "$CHECK_SCRIPT" 2>/dev/null || true
fi

if [[ -n $CSV_PATH ]]; then
  echo "alumno,nota,observaciones" > "$CSV_PATH"
fi

for alumno_dir in "$ALUMNOS_DIR"/*; do
  [[ -d "$alumno_dir" ]] || continue
  alumno="$(basename "$alumno_dir")"
  tarball="$(find "$alumno_dir" -maxdepth 1 -type f -name '*.tar.gz' | head -n1 || true)"

  if [[ -z $tarball ]]; then
    echo "$alumno -> SIN ENTREGA"
    if [[ -n $CSV_PATH ]]; then
      echo "$alumno,0,SIN ENTREGA" >> "$CSV_PATH"
    fi
    continue
  fi

  output="$("$CHECK_SCRIPT" "$tarball")"
  score="$(rg -o 'Puntuacion: [0-9.]+/10' <<<"$output" | rg -o '[0-9.]+' | head -n1 || true)"
  score="${score:-0}"

  echo "$alumno -> $score/10"
  if [[ -n $CSV_PATH ]]; then
    echo "$alumno,$score,OK" >> "$CSV_PATH"
  fi
done
