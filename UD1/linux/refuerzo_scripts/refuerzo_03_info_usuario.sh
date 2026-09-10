#!/usr/bin/env bash
# Refuerzo 03: consultar datos de un usuario
# ENUNCIADO:
# 1. Recibe un nombre de usuario por argumento (usa el actual si no llega nada).
# 2. Consulta la entrada en /etc/passwd con getent.
# 3. Muestra directorio personal y shell por defecto.

if [ -n "$1" ]
then
  usuario="$1"
else
  usuario="$(whoami)"
fi

if ! entrada=$(getent passwd "$usuario")
then
  echo "El usuario $usuario no existe en el sistema." >&2
  exit 1
fi

home=$(echo "$entrada" | cut -d: -f6)
shell=$(echo "$entrada" | cut -d: -f7)

echo "Usuario: $usuario"
echo "Directorio personal: $home"
echo "Shell por defecto: $shell"
