#!/usr/bin/env bash
# Refuerzo 07: asegurar ejecucion para el grupo
# ENUNCIADO:
# 1. Recibir un directorio (o usar el actual).
# 2. Localizar todos los scripts .sh que contenga.
# 3. Anadir permiso de ejecucion para el grupo y mostrar el resultado.

dir="."
if [ -n "$1" ]
then
  dir="$1"
fi

if [[ ! -d $dir ]]
then
  echo "Debes indicar un directorio valido." >&2
  exit 1
fi

procesados=0

for script in "$dir"/*.sh
do
  if [ ! -f "$script" ]
  then
    continue
  fi

  procesados=$((procesados + 1))
  chmod g+x "$script"
  echo "Permiso de ejecucion para grupo aplicado a: $script"
  ls -l "$script"
done

if [ "$procesados" -eq 0 ]
then
  echo "No hay scripts .sh en $dir"
fi
