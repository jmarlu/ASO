#!/usr/bin/env bash
# Refuerzo 04: comprobar si un numero es par o impar
# ENUNCIADO:
# 1. Pedir por teclado un numero entero.
# 2. Validar que realmente sea entero.
# 3. Decir si es par o impar usando aritmetica con (( )).

read -rp "Introduce un numero entero: " numero
if [[ ! $numero =~ ^-?[0-9]+$ ]]
then
  echo "Debes introducir un numero entero." >&2
  exit 1
fi

if (( numero % 2 == 0 ))
then
  echo "$numero es par."
else
  echo "$numero es impar."
fi
