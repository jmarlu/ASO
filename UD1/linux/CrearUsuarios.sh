#!/bin/bash

archivo="usuarios.txt"

case $1 in
  a|A)
    intentos=0
    while (( intentos < 3 )); do
      read -r -p "Usuario: " usuario
      read -r -s -p "Contraseña: " contrasena
      echo
      # Uso de grep -xF en lugar de grep -P
      if grep -xF "$usuario $contrasena" "$archivo" >/dev/null; then
        echo "Bienvenido $usuario"
        exit 0
      else
        echo "Login incorrecto."
        ((intentos++))
      fi
    done
    echo "Se superó el número máximo de intentos."
    ;;
  b|B)
    echo "Bienvenido $usuario"
    exit 0
    ;;
  *)
    echo "Uso: $0 [a|A|b|B]"
    exit 1
    ;;
esac