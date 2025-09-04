# Comandos Windows

Aquí se incluirán los comandos básicos y avanzados para trabajar en sistemas Windows.

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
1. Introduce el comando para mostrar el contenido de un archivo llamado `prueba.txt`.
2. Introduce el comando para contar las líneas de un archivo llamado `prueba.txt`.
3. Introduce el comando para buscar la palabra "administrador" en un archivo llamado `usuarios.txt`.

## Ejercicios avanzados

### Ejercicio 1: Listado de archivos y directorios
1. Introduce el comando para listar todos los archivos y directorios, incluidos los ocultos, en el directorio raíz.
2. Introduce el comando para obtener una lista detallada de todos los archivos y directorios, incluidos los contenidos de los subdirectorios, en `C:\Usuarios`.
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
2. Introduce un comando para cambiar el propietario de un archivo al usuario `Administrador`.
3. Introduce un comando para añadir permisos de ejecución a todos los archivos con extensión `.ps1` en tu directorio actual.

### Ejercicio 5: Búsqueda y manipulación de archivos
1. Introduce un comando para buscar en tu directorio personal todos los archivos que comiencen con la letra `t` y modificar su fecha de actualización a la actual.
2. Introduce un comando para buscar todos los archivos en el sistema que sean menores de 1 MB y pertenezcan al usuario `Administrador`, y guarda sus nombres en un archivo llamado `ficheros_pequeños`.
3. Introduce un comando para buscar todos los archivos del usuario `Invitado` que ocupen más de 5000 MB y tengan permisos de escritura, y elimínalos.

### Ejercicio 6: Procesamiento de contenido
1. Introduce un comando para mostrar el contenido de un archivo llamado `usuarios.txt` y reemplazar los dos puntos (`:`) por guiones bajos (`_`).
2. Introduce un comando para mostrar solo las líneas del archivo `usuarios.txt` que correspondan al usuario `Administrador`.
3. Introduce un comando para contar el número de líneas en el archivo `usuarios.txt` que contengan la palabra "PowerShell".

### Ejercicio 7: Redirecciones
1. Introduce un comando para redirigir la salida estándar del contenido de un archivo llamado `registro.log` al final de un archivo llamado `salida.txt` y los errores a un archivo llamado `errores.txt`.
2. Introduce un comando para obtener las tres últimas líneas de un archivo llamado `t1` y guardar el resultado en un archivo llamado `resultado.txt`.
3. Introduce un comando para redirigir la salida de un comando que liste los archivos en el directorio actual a un archivo llamado `listado.txt`, y los errores a un archivo llamado `errores_listado.txt`.

## Resumen de comandos que se utilizan en los ejercicios. 

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `Get-Location` | Muestra el directorio actual de trabajo. | `Get-Location` devuelve `C:\Usuarios\Admin` si estás en ese directorio. |
| `Get-ChildItem` | Lista los archivos y directorios en la ubicación actual. | `Get-ChildItem` muestra `archivo1 archivo2 directorio1`. |
| `New-Item` | Crea un nuevo archivo o directorio. | `New-Item -Name prueba.txt -ItemType File` crea un archivo llamado `prueba.txt`. |
| `Set-Location` | Cambia de directorio. | `Set-Location C:\` te lleva al directorio raíz. |
| `Remove-Item` | Elimina archivos o directorios. | `Remove-Item -Recurse -Force nuevo_directorio` elimina el directorio y su contenido. |
| `Get-Content` | Muestra el contenido de un archivo. | `Get-Content prueba.txt` muestra el contenido de `prueba.txt`. |
| `Select-String` | Busca patrones en un archivo. | `Select-String -Path usuarios.txt -Pattern "admin"` busca "admin" en el archivo. |
| `$Env:` | Accede a variables de entorno. | `$Env:USERPROFILE` muestra el directorio personal del usuario. |
| `Copy-Item` | Copia archivos o directorios. | `Copy-Item * -Destination D1` copia todos los archivos al directorio `D1`. |
| `Move-Item` | Mueve o renombra archivos o directorios. | `Move-Item archivo.txt -Destination D1` mueve `archivo.txt` al directorio `D1`. |
| `icacls` | Cambia permisos de archivos o directorios. | `icacls archivo /grant:r Everyone:R` da permisos de solo lectura a todos. |
| `ForEach-Object` | Itera sobre objetos en un pipeline. | `Get-ChildItem | ForEach-Object { $_.Name }` muestra los nombres de los archivos. |
| `Set-Content` | Escribe contenido en un archivo. | `"Texto" | Set-Content archivo.txt` escribe "Texto" en `archivo.txt`. |
| `Out-File` | Redirige la salida a un archivo. | `Get-ChildItem | Out-File listado.txt` guarda la lista de archivos en `listado.txt`. |
| `Where-Object` | Filtra objetos en un pipeline. | `Get-ChildItem | Where-Object { $_.Length -gt 1MB }` filtra archivos mayores de 1 MB. |
| `Get-Date` | Obtiene la fecha y hora actuales. | `Get-Date` devuelve la fecha y hora actuales. |
| `Set-ItemProperty` | Cambia propiedades de un archivo o directorio. | `Set-ItemProperty -Path archivo.txt -Name IsReadOnly -Value $true` hace que el archivo sea de solo lectura. |
