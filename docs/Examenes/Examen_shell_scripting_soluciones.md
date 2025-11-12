# Soluciones guía · Examen Shell Scripting (UD1)
---
search:
  exclude: true
---
Cada propuesta utiliza únicamente herramientas vistas en clase (bash, bc, cut, tr, grep). Ajusta rutas y datos a tu entorno antes de ejecutar.

## Ejercicio 1 · `doble.sh`
```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 numero" >&2
  exit 1
fi

valor=$1
num_regex='^-?[0-9]+([.][0-9]+)?$'

if [[ ! $valor =~ $num_regex ]]; then
  echo "El argumento debe ser numérico" >&2
  exit 1
fi

doble=$(echo "$valor * 2" | bc -l)
echo "El doble de $valor es $doble"
```
Prueba sugerida:
```
chmod +x doble.sh
./doble.sh 4.5
./doble.sh texto   # debe mostrar error
```

## Ejercicio 2 · `inventario_grupos.sh`
```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 fichero_grupos" >&2
  exit 1
fi

fichero=$1

if [[ ! -f $fichero ]]; then
  echo "No existe el fichero $fichero" >&2
  exit 1
fi

fallos=0

echo -e "Grupo\tGID\tTotal\tMiembros"
while IFS= read -r grupo; do
  [[ -z $grupo ]] && continue
  echo "$grupo" | grep -q '^#' && continue
  linea=$(getent group "$grupo")
  if [[ -z $linea ]]; then
    echo "Grupo $grupo no existe" >&2
    ((fallos++))
    continue
  fi
  gid=$(echo "$linea" | cut -d: -f3)
  miembros=$(echo "$linea" | cut -d: -f4)
  if [[ -z $miembros ]]; then
    total_miembros=0
    miembros="(sin miembros)"
  else
    total_miembros=$(echo "$miembros" | tr ',' '\n' | grep -c .)
  fi
  echo -e "$grupo\t$gid\t$total_miembros\t$miembros"
done < "$fichero"

if [[ $fallos -gt 0 ]]; then
  exit 1
fi
```
Prueba:
```
cat > grupos.txt <<'LISTA'
# grupos
sudo
video
inexistente
LISTA
chmod +x inventario_grupos.sh
./inventario_grupos.sh grupos.txt
```

## Ejercicio 3 · `alertas_equipos.sh`
```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 umbral_minimo" >&2
  exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ ]]; then
  echo "El umbral debe ser un número entero positivo" >&2
  exit 1
fi

umbral=$1
fichero="equipos.txt"

if [[ ! -f $fichero ]]; then
  echo "No existe $fichero" >&2
  exit 1
fi

alertas=0
linea_num=0
while read -r ip nombre disco ram; do
  ((linea_num++))
  [[ -z $ip ]] && continue
  echo "$ip" | grep -q '^#' && continue
  if ! [[ $disco =~ ^[0-9]+$ ]]; then
    echo "Línea $linea_num: valor de disco no válido" >&2
    continue
  fi
  if (( disco < umbral )); then
    echo "ALERTA: $nombre ($ip) tiene ${disco}GB libres (< ${umbral}GB)"
    ((alertas++))
  fi
done < "$fichero"

echo "Resumen: $alertas equipos bajo el umbral"
```
Prueba:
```
cat > equipos.txt <<'EQS'
10.0.0.5 srv01 20 8
10.0.0.6 srv02 80 16
# línea ignorada
EQS
chmod +x alertas_equipos.sh
./alertas_equipos.sh 40
```
