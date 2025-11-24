---
search:
  exclude: true
---


# Soluciones y explicaciones de las actividades de shell scripting

Este documento recopila una propuesta de solución para cada actividad incluida en `docs/UD1/linux/Actividades.md`. Los guiones se han revisado para que sean robustos, fáciles de mantener y compatibles con distribuciones GNU/Linux actuales. Cuando un comando requiere privilegios elevados se indica expresamente.

## Introducción

### Actividad 1. Configuración del script `micomando`

Creamos el directorio `~/bin`, colocamos el script y añadimos la ruta al `PATH` del usuario (por ejemplo en `~/.bashrc`).

#### Script: `micomando`
```bash
#!/bin/bash
echo "Ejecución de micomando"
```

#### Pasos recomendados
- `mkdir -p "$HOME/bin"` y guardar el script como `$HOME/bin/micomando`.
- Dar permisos de ejecución: `chmod u+x "$HOME/bin/micomando"`.
- Añadir al final de `~/.bashrc`: `export PATH="$HOME/bin:$PATH"`.
- Recargar la configuración (`source ~/.bashrc`) o abrir una sesión nueva.

### Actividad 2. Scripts de saludo

#### Script: `Script1_1.sh`
```bash
#!/bin/bash
read -r -p "Bienvenido, introduce tu nombre y apellidos: " fullname

if [[ -z $fullname ]]; then
  echo "No se ha introducido ningún nombre." >&2
  exit 1
fi

echo "Que tengas un próspero día $fullname"
```

#### Script: `Script1_1_2.sh`
```bash
#!/bin/bash
read -r -p "Inserta un nombre: " nombre
read -r -p "Inserta un apellido: " apellido

if [[ -z $nombre || -z $apellido ]]; then
  echo "Nombre y apellido son obligatorios." >&2
  exit 1
fi

echo "Bienvenido $nombre, tu apellido es $apellido"
```

### Actividad 3. Alta de usuarios (`Script1_2.sh`)

```bash
#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Este script debe ejecutarse como root." >&2
  exit 1
fi

read -r -p "Inserta un nombre de usuario: " usuario
read -r -p "Inserta una ruta de directorio home: " ruta_home
read -r -p "Elige un shell de comandos [/bin/bash]: " shell
shell=${shell:-/bin/bash}

if [[ -z $usuario || -z $ruta_home ]]; then
  echo "El usuario y la ruta home son obligatorios." >&2
  exit 1
fi

if ! command -v useradd >/dev/null; then
  echo "useradd no está disponible en el sistema." >&2
  exit 1
fi

if ! getent passwd "$usuario" >/dev/null; then
  useradd -m -d "$ruta_home" -s "$shell" "$usuario"
  resultado=$?
else
  echo "El usuario $usuario ya existe." >&2
  exit 1
fi

if [[ $resultado -eq 0 ]]; then
  echo "Usuario creado correctamente."
else
  echo "No se pudo crear el usuario (código $resultado)." >&2
  exit $resultado
fi
```

### Actividad 4. Interpretación de comandos

Se interpretan las once instrucciones solicitadas asumiendo que existen ficheros `f1`, `f2` y `f3`. El ítem 2 se interpreta como `echo \*`, corrigiendo el pequeño error tipográfico del enunciado.

| Comando                           | Salida orientativa           | Explicación                                                                 |
| --------------------------------- | ---------------------------- | ---------------------------------------------------------------------------- |
| `echo *`                         | `f1 f2 f3`                   | Expande el comodín `*` a todos los ficheros del directorio actual.          |
| `echo \*`                        | `*`                          | El `\` evita la expansión del comodín.                                      |
| `echo "*"`                       | `*`                          | Las comillas dobles bloquean la expansión de comodines.                     |
| `echo '\*'`                      | `\*`                         | Las comillas simples muestran el texto literal, incluido el `\`.            |
| `edad=20`                        | *(sin salida)*               | Asigna el valor `20` a la variable `edad`.                                  |
| `echo $edad`                     | `20`                         | Expande la variable `edad`.                                                 |
| `echo \$edad`                    | `$edad`                      | Escapa el símbolo `$` para mostrarlo tal cual.                              |
| `echo "$edad"`                   | `20`                         | Las comillas dobles permiten la expansión de variables.                     |
| `echo '$edad'`                   | `$edad`                      | Las comillas simples impiden la expansión.                                  |
| `echo "Tú eres $(logname) y tienes -> $edad años"` | `Tú eres usuario y tienes -> 20 años` | Sustituye `$(logname)` por el usuario que ejecuta el script.                |
| `echo Tú eres $(logname) y tienes -> $edad años`   | `Tú eres usuario y tienes -> 20 años` | Igual que el anterior, sin comillas porque no existen espacios en variables. |

### Actividad 5. Comparación de cadenas

```bash
#!/bin/bash

s1=si
s2=no
vacia=""
arch1=informe.pdf

[[ $s1 == $s2 ]] && echo "s1 y s2 son iguales" || echo "s1 y s2 son diferentes"
[[ $s1 != $s2 ]] && echo "s1 y s2 son distintos"
[[ -z $vacia ]] && echo "vacia está vacía"
[[ -n $vacia ]] && echo "vacia no está vacía" || echo "vacia sigue vacía"
```

### Actividad 6. Comparaciones numéricas

```bash
#!/bin/bash

num1=2
num2=100

if [ "$num1" -gt "$num2" ]; then
  echo "[ ]: num1 es mayor que num2"
else
  echo "[ ]: num1 NO es mayor que num2"
fi

if [[ num1 -gt num2 ]]; then
  echo "[[ ]]: num1 es mayor que num2"
else
  echo "[[ ]]: num1 NO es mayor que num2"
fi

if (( num1 > num2 )); then
  echo "(( )): num1 es mayor que num2"
else
  echo "(( )): num1 NO es mayor que num2"
fi
```

### Actividad 7. Evaluación de permisos

```bash
#!/bin/bash

archivo=arch

if [[ ! -x $archivo ]]; then
  echo "Permiso x no indicado"
fi

if [[ ! -x $archivo && ! -w $archivo ]]; then
  echo "Permisos wx no indicados"
fi
```

## Estructura IF

### Actividad 1. `Script_IF_1.sh`

```bash
#!/bin/bash

read -r -p "Introduce un número: " numero

if ! [[ $numero =~ ^-?[0-9]+$ ]]; then
  echo "Debes introducir un entero." >&2
  exit 1
fi

if (( numero % 2 == 0 )); then
  echo "El número $numero es par."
else
  echo "El número $numero es impar."
fi
```

### Actividad 2. `Script_IF_2.sh`

```bash
#!/bin/bash

read -r -p "Introduce el primer número: " n1
read -r -p "Introduce el segundo número: " n2
read -r -p "Introduce la operación (+, -, *, /): " operacion

if ! [[ $n1 =~ ^-?[0-9]+(\.[0-9]+)?$ && $n2 =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Los valores deben ser numéricos." >&2
  exit 1
fi

case $operacion in
  +|-|\*|/)
    resultado=$(echo "$n1 $operacion $n2" | bc -l)
    echo "Resultado: $resultado"
    ;;
  *)
    echo "Operación no soportada." >&2
    exit 1
    ;;
esac
```

### Actividad 3. `Script_IF_3.sh`

```bash
#!/bin/bash

read -r -p "Introduce el primer número: " n1
read -r -p "Introduce el segundo número: " n2
read -r -p "Introduce la operación (+, -, *, /): " operacion

if ! [[ $n1 =~ ^-?[0-9]+(\.[0-9]+)?$ && $n2 =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Los valores deben ser numéricos." >&2
  exit 1
fi

case $operacion in
  +|-|\*|/)
    resultado=$(echo "$n1 $operacion $n2" | bc -l)
    ;;
  *)
    echo "Operación no soportada." >&2
    exit 1
    ;;
esac

read -r -p "¿Quieres decimales (s/n)? " decimales

if [[ $decimales == "s" || $decimales == "S" ]]; then
  echo "Resultado: $resultado"
elif [[ $decimales == "n" || $decimales == "N" ]]; then
  printf "Resultado: %.0f\n" "$resultado"
else
  echo "No has seleccionado ninguna opción." >&2
  exit 1
fi
```

### Actividad 4. `Script_IF_4.sh`

```bash
#!/bin/bash

read -r -p "Introduce una IP: " ip

if [[ -z $ip && $ip=~[0-9]{1,3}\.){3}[0-9]{1,3} ]]; then
  echo "Debes introducir una dirección IP o un dominio." >&2
  exit 1
fi

echo "Selecciona una opción:"
echo "1. ping"
echo "2. traceroute"
echo "3. whois"

read -r -p "Opción: " opcion

case $opcion in
  1)
    command -v ping >/dev/null || { echo "ping no está instalado." >&2; exit 1; }
    ping -c 4 "$ip"
    ;;
  2)
    command -v traceroute >/dev/null || { echo "traceroute no está instalado." >&2; exit 1; }
    traceroute "$ip"
    ;;
  3)
    command -v whois >/dev/null || { echo "whois no está instalado." >&2; exit 1; }
    whois "$ip"
    ;;
  *)
    echo "No has seleccionado ninguna opción válida." >&2
    exit 1
    ;;
esac
```

### Actividad 5. `Script_IF_5.sh`

```bash
#!/bin/bash

read -r -p "Introduce una ruta absoluta: " ruta

if [[ -z $ruta && $ruta=~ ^\/ ]]; then
  echo "Debes introducir una ruta." >&2
  exit 1
fi

echo "Información sobre $ruta"

if [[ -d $ruta ]]; then
  echo "1. Es un directorio."
elif [[ -f $ruta ]]; then
  echo "1. Es un fichero."
  [[ -r $ruta ]] && echo "2. Tiene permisos de lectura."
  [[ -w $ruta ]] && echo "3. Tiene permisos de escritura."
  [[ -x $ruta ]] && echo "4. Tiene permisos de ejecución."
else
  echo "1. No existe."
fi
```

## Argumentos

### Actividad 1. Información de fichero (`scriptArgs_2.sh`)

```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "ERROR NÚMERO DE ARGUMENTOS INCORRECTO" >&2
  exit 1
fi

archivo=$1

if [[ ! -f $archivo ]]; then
  echo "EL ARGUMENTO DEBE SER UN FICHERO" >&2
  exit 1
fi

propietario=$(stat -c %U "$archivo")
permisos=$(stat -c %A "$archivo" | cut -c 8-10)

echo "El propietario de $(basename "$archivo") es $propietario y los permisos para el resto son $permisos"
```

### Actividad 2. Datos de usuario (`scriptArgs_3.sh`)

```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "ERROR, NÚMERO DE ARGUMENTOS INCORRECTOS" >&2
  exit 1
fi

usuario=$1

if ! getent passwd "$usuario" >/dev/null; then
  echo "El usuario $usuario no existe." >&2
  exit 1
fi

uid=$(getent passwd "$usuario" | cut -d: -f3)
shell=$(getent passwd "$usuario" | cut -d: -f7)

echo "El uid de $usuario es $uid y tiene el shell $shell"
```

### Actividad 3. Gestión de `blacklist` (`blacklist.sh`)

```bash
#!/bin/bash

lista="blacklist.txt"

if [[ $# -ne 1 ]]; then
  echo "Debes pasar un nombre de usuario como argumento" >&2
  exit 1
fi

usuario=$1

touch "$lista"

echo "Seleccione una opción"
echo "1. Agregar usuario a blacklist"
echo "2. Eliminar usuario de blacklist"
read -r -p "Opción: " opcion

case $opcion in
  1)
    if grep -qx "$usuario" "$lista"; then
      echo "Usuario ya bloqueado con anterioridad" >&2
      exit 1
    fi
    echo "$usuario" >> "$lista"
    if id "$usuario" >/dev/null 2>&1; then
      usermod -L "$usuario"
    fi
    echo "Usuario $usuario bloqueado"
    ;;
  2)
    if ! grep -qx "$usuario" "$lista"; then
      echo "El usuario no estaba bloqueado." >&2
      exit 1
    fi
    grep -vx "$usuario" "$lista" > "${lista}.tmp" && mv "${lista}.tmp" "$lista"
    if id "$usuario" >/dev/null 2>&1; then
      usermod -U "$usuario"
    fi
    echo "Usuario $usuario desbloqueado"
    ;;
  *)
    echo "Opción no válida." >&2
    exit 1
    ;;
esac
```

## Case y While

### Actividad 1. Menú de red (`menu_red.sh`)

```bash
#!/bin/bash


if [[ $# -ne 1 || ! $ip=~[0-9]{1,3}\.){3}[0-9]{1,3} ]]; then
  echo "Debes indicar una IP o dominio como argumento." >&2
  exit 1
fi

ip=$1

while true; do
  cat <<EOF
Seleccione una opción:
1. ping
2. tracepath
3. nslookup
4. whois
5. salir
EOF

  read -r -p "Opción: " opcion

  case $opcion in
    1)
      ping -c 4 "$ip"
      ;;
    2)
      if ! command -v tracepath >/dev/null; then
        echo "tracepath no está disponible." >&2
        continue
      fi
      tracepath "$ip"
      ;;
    3)
      if ! command -v nslookup >/dev/null; then
        echo "nslookup no está disponible." >&2
        continue
      fi
      nslookup "$ip"
      ;;
    4)
      if ! command -v whois >/dev/null; then
        echo "whois no está disponible." >&2
        continue
      fi
      whois "$ip"
      ;;
    5)
      echo "Fin del programa."
      exit 0
      ;;
    *)
      echo "OPCIÓN DESCONOCIDA" >&2
      ;;
  esac
done
```

### Actividad 2. Validación con `usuarios.log` (`login.sh`)

```bash
#!/bin/bash

max_intentos=3
intentos=0
archivo="usuarios.log"

if [[ ! -f $archivo ]]; then
  echo "No existe el fichero $archivo" >&2
  exit 1
fi

while (( intentos < max_intentos )); do
  read -r -p "Usuario: " usuario
  read -r -s -p "Contraseña: " contrasena
  echo

  if [[ -z $usuario || -z $contrasena ]]; then
    echo "Usuario y contraseña son obligatorios." >&2
    ((intentos++))
    continue
  fi

  if grep -qxF "$usuario"$'\t'"$contrasena' "$archivo" >/dev/null; then
    echo "Bienvenido $usuario"
    exit 0
  else
    echo "Credenciales incorrectas."
    ((intentos++))
  fi
done

echo "Usuario Incorrecto"
exit 1
```

### Actividad 3. Menú `CrearUsuarios.sh`

```bash
#!/bin/bash

archivo="cuentas.log"
touch "$archivo"

while true; do
  cat <<EOF
a. Log in
b. Registrarse
c. Salir
EOF

  read -r -p "Selecciona una opción: " opcion

  case $opcion in
    a|A)
      intentos=0
      while (( intentos < 3 )); do
        read -r -p "Usuario: " usuario
        read -r -s -p "Contraseña: " contrasena
        echo
        if grep -qxF "$usuario"$'\t'"$contrasena' "$archivo" >/dev/null; then
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
      read -r -p "Nuevo usuario: " nuevo
      read -r -s -p "Contraseña: " pass1
      echo
      read -r -s -p "Repite la contraseña: " pass2
      echo

      if [[ $pass1 != $pass2 ]]; then
        echo "Contraseñas no coinciden."
        continue
      fi

      if grep -x +"$nuevo" "$archivo" >/dev/null; then
        echo "El usuario ya existe."
        continue
      fi

      echo "$nuevo $pass1" >> "$archivo"
      echo "Usuario registrado correctamente."
      ;;
    c|C)
      echo "Saliendo..."
      exit 0
      ;;
    *)
      echo "OPCIÓN INCORRECTA"
      ;;
  esac
done
```

## For

### Actividad 1. Traza de `ejemploContinue.sh`

Ejecución ejemplo: `bash ./ejemploContinue.sh 3`

| Iteración | Valor de `i` | `resto` (`i % 3`) | Acción              |
| --------- | ------------ | ----------------- | ------------------- |
| 1         | 1            | 1                 | `continue`          |
| 2         | 2            | 2                 | `continue`          |
| 3         | 3            | 0                 | Se muestra `3`      |
| 4         | 4            | 1                 | `continue`          |
| 5         | 5            | 2                 | `continue`          |
| 6         | 6            | 0                 | Se muestra `6`      |
| 7         | 7            | 1                 | `continue`          |
| 8         | 8            | 2                 | `continue`          |
| 9         | 9            | 0                 | Se muestra `9`      |
| 10        | 10           | 1                 | `continue`          |

### Actividad 2. Expiración de contraseñas (`expira.sh`)

```bash
#!/bin/bash
IFS=
if [[ $# -ne 1 ]]; then
  echo "Debes indicar el número de días como argumento." >&2
  exit 1
fi

dias=$1
archivo="expira.log"

if [[ ! -f $archivo ]]; then
  echo "No existe el fichero $archivo" >&2
  exit 1
fi

while  read -r usuario; do
  [[ -z $usuario ]] && continue
  if id "$usuario" >/dev/null 2>&1; then
    chage -M "$dias" "$usuario"
    echo "Actualizada la caducidad de $usuario a $dias días."
  else
    echo "El usuario $usuario no existe." >&2
  fi
done < "$archivo"
```

### Actividad 3. Tabla con asteriscos (`tabla.sh`)

```bash
#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Uso: $0 filas columnas" >&2
  exit 1
fi

filas=$1
columnas=$2

if ! [[ $filas =~ ^[0-9]+$ && $columnas =~ ^[0-9]+$ ]]; then
  echo "Ambos argumentos deben ser enteros positivos." >&2
  exit 1
fi

for (( i=1; i<=filas; i++ )); do
  linea="*"
  for (( j=2; j<=columnas; j++ )); do
    linea+=" *"
  done
  echo "$linea"
done
```

## For-in

### Actividad 1. Permisos de ejecución (`permisos_gx.sh`)

```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 directorio" >&2
  exit 1
fi

directorio=$1

if [[ ! -d $directorio ]]; then
  echo "El argumento debe ser un directorio." >&2
  exit 1
fi

for fichero in "$directorio"/*; do
  [[ -f $fichero ]] || continue
  chmod g+x "$fichero"
done

ls -l "$directorio"
```



### Actividad 2. Mover o copiar por extensión (`gestiona_ext.sh`)

```bash
#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Uso: $0 extension directorio_origen directorio_destino" >&2
    exit 1
fi

extension=$1
origen=$2
destino=$3

# Verificar que los directorios existen
if [[ ! -d "$origen" ]] || [[ ! -d "$destino" ]]; then
    echo "Los argumentos segundo y tercero deben ser directorios." >&2
    exit 1
fi


# Buscar archivos con find y almacenar resultado
archivos=$(find "$origen" -maxdepth 1 -name "*.$extension" -type f)

if [[ -z "$archivos" ]]; then
    echo "No se encontraron ficheros con extensión .$extension en $origen"
    exit 0
fi

read -r -p "¿Deseas mover o copiar? [mover/copiar]: " accion

case $accion in
    mover)
        for archivo in $archivos; do
            mv "$archivo" "$destino/"
            echo "Movido: $archivo"
        done
        echo "Ficheros movidos correctamente."
        ;;
    copiar)
        for archivo in $archivos; do
            cp "$archivo" "$destino/"
            echo "Copiado: $archivo"
        done
        echo "Ficheros copiados correctamente."
        ;;
    *)
        echo "Acción no válida." >&2
        exit 1
        ;;
esac
```

### Actividad 3. Alerta de capacidad (`alerta_equipos.sh`)

```bash Title="con while"
#!/bin/bash
IFS=
if [[ $# -ne 1 ]]; then
  echo "Uso: $0 capacidad_minima" >&2
  exit 1
fi
if ! [[ $minimo =~ ^[0-9]+$ ]]; then
  echo "ERROR: La capacidad mínima debe ser un número entero positivo." >&2
  exit 1
fi

minimo=$1
archivo="equipos.txt"

if [[ ! -f $archivo ]]; then
  echo "No existe el fichero $archivo" >&2
  exit 1
fi

IFS=

while read -r ip nombre disco ram; do
  [[ -z $ip ]] && continue
  if (( disco < minimo )); then
    echo "ALERTA: $nombre ($ip) tiene ${disco}GB libres (< ${minimo}GB)."
  fi
done < "$archivo"

```
```bash title="con For"

#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 capacidad_minima" >&2
  exit 1
fi

minimo=$1
if ! [[ $minimo =~ ^[0-9]+$ ]]; then
  echo "ERROR: La capacidad mínima debe ser un número entero positivo." >&2
  exit 1
fi

archivo="equipos.txt"

if [[ ! -f $archivo ]]; then
  echo "No existe el fichero $archivo" >&2
  exit 1
fi

# Iteramos con for sobre las líneas del fichero
# Usamos IFS=$'\n' y desactivamos globbing para que cada elemento sea una línea completa
OLDIFS=$IFS
IFS=$'\n'
for linea in $(cat "$archivo"); do
  # Ignorar líneas vacías y comentarios
  [[ -z "${linea// }" ]] && continue
  [[ $linea =~ ^# ]] && continue

  # Extraemos: IP;NOMBRE;DISCO;RAM
  ip=$(echo "$linea" | cut -d';' -f1)
  nombre=$(echo "$linea" | cut -d';' -f2)
  disco_num=$(echo "$linea" | cut -d';' -f3)
  ram_num=$(echo "$linea" | cut -d';' -f4)
  
 

  echo "IP: $ip  Nombre: $nombre  Disco: ${disco_num}GB  RAM: ${ram_num}GB"

  if (( disco_num < minimo )); then
    echo "ALERTA: $nombre ($ip) tiene ${disco_num}GB libres (< ${minimo}GB)."
  fi
done
IFS=$OLDIFS


```

### Actividad 4. Creación remota de usuarios (`creaUsuarios.sh`)

```bash
#!/bin/bash

hosts="hosts.txt"
usuarios="usuarios.txt"

if [[ ! -f $hosts || ! -f $usuarios ]]; then
  echo "Deben existir los ficheros hosts.txt y usuarios.txt" >&2
  exit 1
fi

read -r -s -p "Introduce la contraseña de root para los hosts remotos: " password
echo

while read -r host; do
  [[ -z $host ]] && continue
  while read -r usuario; do
    [[ -z $usuario ]] && continue
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no root@"$host" "userdel -rf \"$usuario\" 2>/dev/null; useradd -m \"$usuario\""
    echo "Usuario $usuario recreado en $host"
  done < "$usuarios"
done < "$hosts"
```

> ℹ️ En entornos reales conviene usar autenticación con claves, cifrado de contraseñas y gestionar errores individualmente.

### Actividad 5. Creación remota con claves (`creaUsuariosClaves.sh`)

```bash
#!/bin/bash

set -euo pipefail

hosts="hosts.txt"
usuarios="usuarios.txt"
clave_publica="${1:-clave.pub}"
clave_admin="${HOME}/.ssh/lab_admin"
clave_pruebas="${clave_publica%.pub}"

if [[ ! -f $hosts || ! -f $usuarios ]]; then
  echo "Deben existir los ficheros hosts.txt y usuarios.txt" >&2
  exit 1
fi

if [[ ! -f $clave_publica ]]; then
  echo "No encuentro la clave pública a desplegar: $clave_publica" >&2
  exit 1
fi

if [[ ! -f $clave_admin ]]; then
  echo "No encuentro la clave privada administrativa: $clave_admin" >&2
  echo "Ejecuta: ssh-keygen -t ed25519 -f \"$clave_admin\"" >&2
  exit 1
fi

llave_publica=$(<"$clave_publica")

while read -r host; do
  [[ -z $host ]] && continue
  while read -r usuario; do
    [[ -z $usuario ]] && continue
    ssh -i "$clave_admin" \
        -o BatchMode=yes \
        -o StrictHostKeyChecking=accept-new \
        root@"$host" bash -s <<EOF
set -e
userdel -rf "$usuario" 2>/dev/null || true
useradd -m "$usuario"
install -d -m 700 -o "$usuario" -g "$usuario" "/home/$usuario/.ssh"
cat <<'__KEY__' > "/home/$usuario/.ssh/authorized_keys"
$llave_publica
__KEY__
chown -R "$usuario:$usuario" "/home/$usuario/.ssh"
chmod 600 "/home/$usuario/.ssh/authorized_keys"
EOF

    if [[ -f $clave_pruebas ]]; then
      if ssh -i "$clave_pruebas" \
             -o BatchMode=yes \
             -o StrictHostKeyChecking=accept-new \
             "$usuario@$host" "echo OK" >/dev/null 2>&1; then
        echo "[$host] Usuario $usuario operativo con acceso por clave."
      else
        echo "[$host] Usuario $usuario creado pero la verificación por clave falló." >&2
      fi
    else
      echo "[$host] Usuario $usuario configurado. Omisión de verificación (clave privada $clave_pruebas no encontrada)."
    fi
  done < "$usuarios"
done < "$hosts"
```

> ✅ Antes de lanzar el script importa la clave pública `lab_admin.pub` en la cuenta `root` de cada host con `ssh-copy-id`. Si proporcionas la clave privada asociada a `clave.pub`, el propio guion comprobará que cada usuario puede autenticarse sin contraseña.
