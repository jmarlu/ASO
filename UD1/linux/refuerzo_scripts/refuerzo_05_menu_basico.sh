#!/usr/bin/env bash
# Refuerzo 05: menu sencillo con while + case
# ENUNCIADO:
# 1. Pedir opciones en un bucle hasta que elija salir.
# 2. Mostrar fecha/hora, ruta+contenido o uso de disco segun la opcion.
# 3. Avisar si la opcion no existe.

opcion=""
while [[ $opcion != 4 ]]
do
  cat <<'MENU'
-------------------------
[1] Mostrar fecha y hora
[2] Ver ruta actual y contenido
[3] Ver uso de disco en el directorio actual
[4] Salir
-------------------------
MENU

  read -rp "Elige una opcion: " opcion
  case $opcion in
    1)
      date
      ;;
    2)
      echo "Estas en: $(pwd)"
      ls -lha
      ;;
    3)
      df -h .
      ;;
    4)
      echo "Hasta luego."
      ;;
    *)
      echo "Opcion no valida."
      ;;
  esac
  echo
  sleep 1
done
