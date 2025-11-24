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

## Ejercicio 2 · `inventario_usuarios.sh`
```bash
#!/bin/bash

# Script: inventario_usuarios.sh
# Propósito: Crear un inventario de usuarios a partir de un fichero
# Uso: ./inventario_usuarios.sh fichero_usuarios

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 fichero_usuarios" >&2
  exit 1
fi

archivo=$1

if [[ ! -f $archivo ]]; then
  echo "ERROR: El fichero '$archivo' no existe." >&2
  exit 1
fi

usuarios_inexistentes=0

echo "========================================================================="
echo "Usuario              UID        Num.Grupos      Grupos"
echo "========================================================================="

OLDIFS=$IFS
IFS=$'\n'
for linea in $(cat "$archivo"); do
  [[ -z "${linea// }" ]] && continue
  [[ $linea =~ ^# ]] && continue

  usuario=$(echo "$linea" | cut -d' ' -f1)

  if ! getent passwd "$usuario" >/dev/null 2>&1; then
    echo "AVISO: El usuario '$usuario' no existe." >&2
    usuarios_inexistentes=1
    continue
  fi

  uid=$(getent passwd "$usuario" | cut -d':' -f3)

  grupos=$(groups "$usuario" 2>/dev/null)
  grupos_limpio=$(echo "$grupos" | cut -d':' -f2)
  num_grupos=$(echo "$grupos_limpio" | wc -w)

  echo "$usuario                ${uid}         ${num_grupos}              ${grupos_limpio}"
done

IFS=$OLDIFS

echo "========================================================================="

if [[ $usuarios_inexistentes -eq 1 ]]; then
  exit 1
else
  exit 0
fi
```
Prueba rápida:
```
cat > usuarios.txt <<'LISTA'
# cuentas a revisar
root
daemon
nadie
LISTA
chmod +x inventario_usuarios.sh
./inventario_usuarios.sh usuarios.txt
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
  # Los valores del disco vienen con el sufijo GB (p.ej., 20GB)
  if ! echo "$disco" | grep -Eq '^[0-9]+GB$'; then
    echo "Línea $linea_num: valor de disco no válido (usa formato 20GB)" >&2
    continue
  fi
  disco_num=$(echo "$disco" | grep -oE '^[0-9]+')
  if (( disco_num < umbral )); then
    echo "ALERTA: $nombre ($ip) tiene ${disco} libres (< ${umbral}GB)"
    ((alertas++))
  fi
done < "$fichero"

echo "Resumen: $alertas equipos bajo el umbral"
```
Prueba:
```
cat > equipos.txt <<'EQS'
10.0.0.5 srv01 20GB 8
10.0.0.6 srv02 80GB 16
# línea ignorada
EQS
chmod +x alertas_equipos.sh
./alertas_equipos.sh 40
```
