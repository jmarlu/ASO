# Soluciones - Actividades Rápidas (UD1 Linux)

Este documento recoge posibles soluciones para las actividades rápidas incluidas al final de cada ficha teórica. Las propuestas son orientativas; puedes adaptarlas según tus necesidades o las de tus alumnos.

## Condicionales `if`

### 1. Comprobar usuario y mostrar `HOME`
```bash
#!/usr/bin/env bash

read -rp "Usuario a consultar: " usuario
if getent passwd "$usuario" >/dev/null
then
    home_dir=$(getent passwd "$usuario" | cut -d: -f6)
    echo "El directorio personal de $usuario es $home_dir"
else
    echo "El usuario $usuario no existe en el sistema."
fi
```

### 2. Mensaje según la hora
```bash
#!/usr/bin/env bash

hora=$(date +%H)
if (( hora >= 11 && hora <= 12 ))
then
    echo "Descanso"
elif (( hora == 14 ))
then
    echo "Comida"
else
    echo "Clase"
fi
```

### 3. Verificar disponibilidad HTTP
```bash
#!/usr/bin/env bash

read -rp "Introduce la URL (ej. https://example.com): " url
codigo=$(curl -Is "$url" | head -n1 | cut -d' ' -f2)

case $codigo in
    200) echo "Servicio OK (200)." ;;
    3*) echo "Redirección (código $codigo)." ;;
    4*) echo "Error del cliente (código $codigo)." ;;
    5*) echo "Error del servidor (código $codigo)." ;;
    *)  echo "No se pudo determinar el estado." ;;
esac
```

## Bucles `for`

### 1. Listar usuarios normales
```bash
#!/usr/bin/env bash

while IFS=: read -r usuario _ uid _ _ _ home _
do
    if (( uid >= 1000 && uid < 65534 ))
    then
        echo "$usuario → UID: $uid, HOME: $home"
    fi
done < <(getent passwd)
```

### 2. Tabla de multiplicar configurable
```bash
#!/usr/bin/env bash

read -rp "Número a multiplicar: " numero
read -rp "Hasta qué factor: " limite

for (( i = 1; i <= limite; i++ ))
do
    resultado=$(( numero * i ))
    printf "%d x %d = %d\n" "$numero" "$i" "$resultado"
done
```

### 3. Monitorizar hosts y registrar resultado
```bash
#!/usr/bin/env bash

hosts=(server1.example.com 192.168.1.10 localhost)
log="monitor.log"
timestamp=$(date '+%F %T')

for host in "${hosts[@]}"
do
    if ping -c1 -W1 "$host" >/dev/null 2>&1
    then
        estado="OK"
    else
        estado="FALLO"
    fi
    echo "$timestamp;$host;$estado" >> "$log"
done
```

## Bucles `while` / `until`

### 1. Ping a lista de IPs
```bash
#!/usr/bin/env bash

while read -r ip
do
    [[ -z $ip ]] && continue
    if ping -c1 -W1 "$ip" >/dev/null 2>&1
    then
        echo "$ip responde."
    else
        echo "$ip no responde."
    fi
done < ips.txt
```

### 2. Reintentar montaje NFS con `until`
```bash
#!/usr/bin/env bash

destino="/mnt/nfs"
try=0
until mountpoint -q "$destino" || (( try == 5 ))
do
    echo "Intento $((try + 1)) de montar $destino..."
    mount "$destino" 2>/dev/null || sleep 5
    (( try++ ))
done

if mountpoint -q "$destino"
then
    echo "Montaje completado."
else
    echo "No fue posible montar $destino tras varios intentos."
fi
```

### 3. Menú interactivo con `while`
```bash
#!/usr/bin/env bash

opcion=""
while [[ $opcion != "4" ]]
do
    cat <<EOF
1) Mostrar fecha
2) Uso de disco
3) Usuario actual
4) Salir
EOF
    read -rp "Elige una opción: " opcion

    case $opcion in
        1) date ;;
        2) df -h / ;;
        3) whoami ;;
        4) echo "Hasta luego." ;;
        *) echo "Opción no válida." ;;
    esac
done
```

## `break`, `continue`, `exit`

### 1. Detener lectura al encontrar `FIN`
```bash
#!/usr/bin/env bash

while IFS= read -r linea
do
    if [[ $linea == "FIN" ]]
    then
        echo "Fin encontrado. Saliendo del bucle."
        break
    fi
    echo "$linea"
done < entrada.txt
```

### 2. Salir si `/var/backups` no es escribible
```bash
#!/usr/bin/env bash

if [[ ! -w /var/backups ]]
then
    echo "No se puede escribir en /var/backups."
    exit 2
fi

echo "Directorio accesible. Continuar con el script..."
```

### 3. Ignorar nombres que empiecen por `test`
```bash
#!/usr/bin/env bash

nombres=(test01 alpha beta testDemo gamma)
for nombre in "${nombres[@]}"
do
    if [[ $nombre == test* ]]
    then
        continue
    fi
    echo "Procesando $nombre"
done
```

## Argumentos

### 1. Validar fichero, directorio y número
```bash
#!/usr/bin/env bash

if [[ $# -ne 3 ]]
then
    echo "Uso: $0 fichero directorio numero"
    exit 1
fi

archivo=$1
directorio=$2
numero=$3

[[ -f $archivo ]]     || { echo "$archivo no es un fichero válido"; exit 1; }
[[ -d $directorio ]]  || { echo "$directorio no es un directorio"; exit 1; }
[[ $numero =~ ^[0-9]+$ ]] || { echo "$numero no es un número"; exit 1; }

echo "Parámetros correctos."
```

### 2. Cuenta atrás con `-n`
```bash
#!/usr/bin/env bash

while [[ $# -gt 0 ]]
do
    case $1 in
        -n)
            objetivo=$2
            shift 2
            ;;
        *)
            echo "Opción desconocida: $1"
            exit 1
            ;;
    esac
done

if [[ -z $objetivo || ! $objetivo =~ ^[0-9]+$ ]]
then
    echo "Uso: $0 -n <numero>"
    exit 1
fi

for (( i = objetivo; i >= 0; i-- ))
do
    echo "$i"
    sleep 1
done
```

### 3. Copiar rutas a `backup/`
```bash
#!/usr/bin/env bash

destino="backup"
mkdir -p "$destino"

for ruta in "$@"
do
    if [[ -f $ruta ]]
    then
        cp "$ruta" "$destino/"
        echo "Copiado $ruta a $destino/"
    else
        echo "Se ignora $ruta (no es un fichero)."
    fi
done
```

## Operadores lógicos

### 1. Validar fichero existente y con contenido
```bash
#!/usr/bin/env bash

read -rp "Fichero a revisar: " fichero
if [[ -f $fichero && -s $fichero ]]
then
    echo "$fichero existe y no está vacío."
else
    echo "$fichero no existe o está vacío."
fi
```

### 2. Servicio activo o puerto escuchando
```bash
#!/usr/bin/env bash

servicio="sshd"
puerto="22"

if systemctl is-active --quiet "$servicio" || ss -ltn | grep -q ":$puerto "
then
    echo "El servicio $servicio está disponible."
else
    echo "Servicio $servicio caído y puerto $puerto sin escucha."
fi
```

### 3. Evaluar número par y múltiplo de 3
```bash
#!/usr/bin/env bash

read -rp "Introduce un número: " numero

if (( numero % 2 == 0 && numero % 3 == 0 ))
then
    echo "$numero es par y múltiplo de 3."
else
    echo "$numero no cumple ambas condiciones."
fi
```
