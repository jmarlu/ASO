# Comandos Linux

## Objetivo
Realizar una serie de ejercicios prácticos para reforzar el uso de comandos básicos y avanzados en Linux, siguiendo una progresión de lo más simple a lo más complejo.
Aquí se incluirán los comandos básicos y avanzados para trabajar en sistemas Linux.

## Introducción

### Ejercicio 1: Exploración básica
1. Introduce el comando para mostrar tu ubicación actual en el sistema.
2. Introduce el comando para listar los archivos y directorios en tu ubicación actual.
3. Introduce el comando para crear un archivo vacío llamado `prueba.txt` en tu ubicación actual.

### Ejercicio 2: Navegación y directorios
1. Introduce el comando para cambiar al directorio raíz del sistema.
2. Introduce el comando para crear un directorio llamado `nuevo_directorio` en tu ubicación actual.
3. Introduce el comando para eliminar el directorio `nuevo_directorio` que creaste anteriormente.

### Ejercicio 3: Visualización de contenido
1. Introduce el comando para mostrar el contenido del archivo `/etc/passwd`.
2. Introduce el comando para contar las líneas de un archivo llamado `prueba.txt`.
3. Introduce el comando para buscar la palabra "root" en el archivo `/etc/passwd`.


## Ejercicios avanzados

### Ejercicio 1: Listado de archivos y directorios
1. Introduce el comando para listar todos los archivos y directorios, incluidos los ocultos, en el directorio raíz.
2. Introduce el comando para obtener una lista detallada de todos los archivos y directorios, incluidos los contenidos de los subdirectorios, en `/home`.
3. Introduce el comando para listar los nombres de los archivos en tu directorio actual que comiencen con la letra `a`.

### Ejercicio 2: Variables de entorno
1. Introduce el comando para mostrar el valor de la variable de entorno que indica el directorio de inicio del usuario actual.
2. Introduce el comando para mostrar el valor de la variable de entorno que contiene las rutas de búsqueda de comandos.
3. Introduce el comando para añadir un nuevo directorio a la variable de entorno PATH.

### Ejercicio 3: Gestión de directorios
1. Introduce un comando para crear un directorio llamado `D1` en tu directorio de trabajo.
2. Introduce un comando para copiar todos los archivos de tu directorio de trabajo al directorio `D1`.
3. Introduce un comando para mover un archivo llamado `archivo.txt` desde tu directorio de trabajo al directorio `D1`.

### Ejercicio 4: Permisos y propietarios
1. Introduce un comando para cambiar los permisos de un archivo para que solo el propietario pueda modificarlo.
2. Introduce un comando para cambiar el propietario de un archivo al usuario `root`.
3. Introduce un comando para añadir permisos de ejecución a todos los archivos con extensión `.sh` en tu directorio actual.

### Ejercicio 5: Búsqueda y manipulación de archivos
1. Introduce un comando para buscar en tu directorio personal todos los archivos que comiencen con la letra `t` y modificar su fecha de actualización a la actual.
2. Introduce un comando para buscar todos los archivos en el sistema que sean menores de 1 MB y pertenezcan al usuario `root`, y guarda sus nombres en un archivo llamado `ficheros_pequeños`.
3. Introduce un comando para buscar todos los archivos del usuario `guest` que ocupen más de 5000 MB y tengan permisos de escritura, y elimínalos.

### Ejercicio 6: Procesamiento de contenido
1. Introduce un comando para mostrar el contenido del archivo `/etc/passwd` y reemplazar los dos puntos (`:`) por guiones bajos (`_`).
2. Introduce un comando para mostrar solo las líneas del archivo `/etc/passwd` que correspondan al usuario `root`.
3. Introduce un comando para contar el número de líneas en el archivo `/etc/passwd` que contengan la palabra "bash".

### Ejercicio 7: Redirecciones
1. Introduce un comando para redirigir la salida estándar del contenido del archivo `/etc/shadow` al final de un archivo llamado `salida.txt` y los errores a un archivo llamado `errores.txt`.
2. Introduce un comando para obtener las tres últimas líneas de un archivo llamado `t1` y guardar el resultado en un archivo llamado `resultado.txt`.
3. Introduce un comando para redirigir la salida de un comando que liste los archivos en el directorio actual a un archivo llamado `listado.txt`, y los errores a un archivo llamado `errores_listado.txt`.

## Resumen de comandos que se utilizan en los ejercicios. 


| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `pwd` | Muestra el directorio actual de trabajo. | `pwd` devuelve `/home/usuario` si estás en tu directorio personal. |
| `ls` | Lista los archivos y directorios en la ubicación actual. | `ls` muestra `archivo1 archivo2 directorio1`. |
| `touch` | Crea un archivo vacío. | `touch prueba.txt` crea un archivo llamado `prueba.txt`. |
| `cd` | Cambia de directorio. | `cd /` te lleva al directorio raíz. |
| `mkdir` | Crea un nuevo directorio. | `mkdir nuevo_directorio` crea un directorio llamado `nuevo_directorio`. |
| `rmdir` | Elimina un directorio vacío. | `rmdir nuevo_directorio` elimina el directorio si está vacío. |
| `cat` | Muestra el contenido de un archivo. | `cat archivo.txt` muestra el contenido de `archivo.txt`. |
| `wc` | Cuenta líneas, palabras y caracteres en un archivo. | `wc -l archivo.txt` cuenta las líneas en `archivo.txt`. |
| `grep` | Busca patrones en un archivo. | `grep "root" /etc/passwd` busca la palabra "root" en el archivo. |
| `find` | Busca archivos y directorios. | `find . -name "*.txt"` busca todos los archivos `.txt` en el directorio actual. |
| `chmod` | Cambia los permisos de un archivo. | `chmod +x script.sh` hace ejecutable el archivo `script.sh`. |
| `chown` | Cambia el propietario de un archivo. | `sudo chown root archivo` asigna el archivo al usuario `root`. |
| `export` | Establece variables de entorno. | `export PATH=$PATH:/nuevo/directorio` añade un directorio al PATH. |
| `tail` | Muestra las últimas líneas de un archivo. | `tail -n 3 archivo.txt` muestra las últimas 3 líneas de `archivo.txt`. |
| `head` | Muestra las primeras líneas de un archivo. | `head -n 5 archivo.txt` muestra las primeras 5 líneas de `archivo.txt`. |
| `echo` | Muestra un mensaje o el valor de una variable. | `echo $HOME` muestra el directorio personal del usuario. |
| `cp` | Copia archivos o directorios. | `cp archivo1 archivo2` copia `archivo1` a `archivo2`. |
| `mv` | Mueve o renombra archivos o directorios. | `mv archivo1 archivo2` renombra `archivo1` a `archivo2`. |
| `rm` | Elimina archivos o directorios. | `rm archivo.txt` elimina el archivo `archivo.txt`. |

### Entrega
- Realiza cada uno de los pasos y toma capturas de pantalla de los resultados.
- Entrega un archivo comprimido con las capturas y los archivos generados durante la práctica.
