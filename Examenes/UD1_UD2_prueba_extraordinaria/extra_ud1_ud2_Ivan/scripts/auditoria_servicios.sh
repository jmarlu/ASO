#!/bin/bash


if  [[ $# -ne 3 ]]
then
	echo "EL numero de argumentos tiene que ser de 3"
	exit 1

elif [[ $3 -ne "" ]]
then
	echo "Estado_esperado no puede estar vacio"
	exit 1
elif [[ -e /extra_ud1_ud2/datos/servicios.txt ]]
then
	echo "hola"
fi

cat /extra_ud1_ud2/datos/servicios.txt


