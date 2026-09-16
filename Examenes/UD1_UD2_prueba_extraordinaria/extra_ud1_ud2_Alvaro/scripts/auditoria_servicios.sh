#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Uso: $0 umbral_disco umbral_ram estado_esperado"
  exit 1
fi

UMBRAL_DISCO=$1
UMBRAL_RAM=$2
ESTADO_ESP=$3

if ! [[ "$UMBRAL_DISCO" =~ ^[0-9]+$ ]]; then
  echo "Error: umbral_disco debe ser un entero"
  exit 1
fi
if ! [[ "$UMBRAL_RAM" =~ ^[0-9]+$ ]]; then
  echo "Error: umbral_ram debe ser un entero"
  exit 1
fi

if [ -z "$ESTADO_ESP" ]; then
  echo "Error: estado_esperado no puede estar vacío"
  exit 1
fi

FICHERO=/home/ubuntu/extra_ud1_ud2/datos/servicios.txt
if [ ! -f "$FICHERO" ]; then
  echo "Error: no existe $FICHERO"
  exit 1
fi

CSV=/home/ubuntu/extra_ud1_ud2/resultados/informe_servicios.csv
echo "ip,nombre,disco,ram,servicio,puerto,tipo,estado" > "$CSV"

n_validos=0; n_formato=0; n_datos=0; n_disco=0; n_ram=0; n_estado=0
min_ram=99999; min_nombre=""; min_ip=""
linea_n=0

clasificar() {
  case $1 in
    nginx|apache2) echo "web" ;;
    mariadb|redis) echo "datos" ;;
    rsync)         echo "copias" ;;
    bind9)         echo "red" ;;
    *)             echo "otros" ;;
  esac
}

while IFS= read -r linea; do
  linea_n=$((linea_n + 1))

  [[ -z "$linea" || "$linea" =~ ^# ]] && continue
  campos=($linea)
  if [ ${#campos[@]} -ne 7 ]; then
    echo "ERROR FORMATO: linea $linea_n"
    n_formato=$((n_formato + 1))
    continue
  fi


  ip=${campos[0]}
  nombre=${campos[1]}
  disco=${campos[2]}
  ram=${campos[3]}
  servicio=${campos[4]}
  puerto=${campos[5]}
  estado=${campos[6]}
if ! [[ "$disco" =~ ^[0-9]+$ ]] || ! [[ "$ram" =~ ^[0-9]+$ ]] || ! [[ "$puerto" =~ ^[0-9]+$ ]]; then
  echo "ERROR DATOS: $nombre ($ip)"
  n_datos=$((n_datos + 1))
  continue
fi
if [ "$disco" -lt "$UMBRAL_DISCO" ]; then
  echo "DISCO BAJO: $nombre ($ip) -> ${disco}GB"
  n_disco=$((n_disco + 1))
fi
if [ "$ram" -lt "$UMBRAL_RAM" ]; then
  echo "RAM BAJA: $nombre ($ip) -> ${ram}GB"
  n_ram=$((n_ram + 1))
fi
if [ "$estado" != "$ESTADO_ESP" ]; then
  echo "ESTADO INCORRECTO: $nombre -> $estado"
  n_estado=$((n_estado + 1))
fi
tipo=$(clasificar "$servicio")

echo "$ip,$nombre,$disco,$ram,$servicio,$puerto,$tipo,$estado" >> "$CSV"

if [ "$ram" -lt "$min_ram" ]; then
  min_ram=$ram
  min_nombre=$nombre
  min_ip=$ip
fi


n_validos=$((n_validos + 1))


done < "$FICHERO"

echo "Resumen: $n_validos validos, $n_formato formato, $n_datos datos, $n_disco disco, $n_ram ram, $n_estado >
echo "Minima RAM: $min_nombre ($min_ip) -> ${min_ram}GB"
