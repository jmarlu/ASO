#!/usr/bin/env bash
# Refuerzo 06: recorrer ficheros y contar lineas
# ENUNCIADO:
# 1. Recibir un directorio (o usar el actual si no se indica).
# 2. Localizar los ficheros .txt de esa ruta usando find.
# 3. Mostrar cuantas lineas tiene cada fichero o avisar si no hay ninguno.

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

lista=$(find "$dir" -maxdepth 1 -type f -name "*.txt")

if [ -z "$lista" ]
then
  echo "No hay ficheros .txt en $dir"
  exit 0
fi

for archivo in $lista
do
  lineas=$(wc -l < "$archivo")
  nombre=$(basename "$archivo")
  echo "$nombre -> $lineas lineas"
done
