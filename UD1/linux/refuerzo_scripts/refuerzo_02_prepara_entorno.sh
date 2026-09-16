#!/usr/bin/env bash
# Refuerzo 02: preparar un pequeno entorno de practica
# ENUNCIADO:
# 1. Pregunta el nombre del directorio de trabajo dentro de HOME.
# 2. Crea el directorio (por defecto "practicas_linux") y un fichero notas.txt.
# 3. Lista el contenido para verificar que todo existe.

read -rp "Nombre del directorio dentro de tu HOME [practicas_linux]: " carpeta
if [ -z "$carpeta" ]
then
  carpeta="practicas_linux"
fi

destino="$HOME/$carpeta"
mkdir -p "$destino"
touch "$destino/notas.txt"

echo "Entorno listo en: $destino"
ls -lha "$destino"
