#!/usr/bin/env bash
# Refuerzo 01: saludo y comandos basicos
# ENUNCIADO:
# 1. Pregunta el nombre de la persona.
# 2. Saluda con ese nombre (o usa "companero" si se deja vacio).
# 3. Muestra fecha, ruta actual y usuario conectado.

read -rp "?Como te llamas? " nombre
if [ -z "$nombre" ]
then
  nombre="companero"
fi

echo "Hola, $nombre."
echo "Hoy es $(date '+%A %d/%m/%Y')."
echo "Estas en $(pwd) con el usuario $(whoami)."
