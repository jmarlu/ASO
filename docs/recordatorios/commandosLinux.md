# Comandos Linux

Aquí se incluirán los comandos básicos y avanzados para trabajar en sistemas Linux.

## Actividad de Repaso: Comandos Linux

### Objetivo
Realizar una serie de ejercicios prácticos para reforzar el uso de comandos básicos y avanzados en Linux, siguiendo una progresión de lo más simple a lo más complejo.

### Instrucciones
1. **Introducción a la Terminal**
   - Abre una terminal en tu sistema Linux.
   - Ejecuta el comando `echo "Hola, Linux"` para imprimir un mensaje en pantalla.

2. **Estructura de Directorios**
   - Navega al directorio `/home` usando `cd`.
   - Crea una estructura de carpetas: `mkdir -p practicaLinux/ejercicios`.
   - Lista el contenido del directorio con `ls -la`.

3. **Gestión de Archivos**
   - Crea un archivo vacío: `touch practicaLinux/ejercicios/archivo1.txt`.
   - Copia el archivo: `cp practicaLinux/ejercicios/archivo1.txt practicaLinux/ejercicios/archivo2.txt`.
   - Mueve el archivo: `mv practicaLinux/ejercicios/archivo2.txt practicaLinux/archivo2.txt`.
   - Elimina el archivo: `rm practicaLinux/archivo2.txt`.

4. **Redirecciones**
   - Redirige la salida de `ls` a un archivo: `ls -la > practicaLinux/listado.txt`.
   - Añade una línea al archivo: `echo "Nueva línea" >> practicaLinux/listado.txt`.

5. **Filtros**
   - Usa `cat` para mostrar el contenido de `listado.txt`.
   - Filtra líneas que contengan la palabra "archivo": `grep "archivo" practicaLinux/listado.txt`.

6. **Búsqueda de Archivos**
   - Busca un archivo llamado `archivo1.txt` en el directorio `practicaLinux`: `find practicaLinux -name archivo1.txt`.

7. **Administración de Memoria Secundaria**
   - Muestra el espacio en disco: `df -h`.
   - Muestra el uso de espacio por directorio: `du -sh practicaLinux`.

8. **Gestor de Arranque**
   - Verifica el gestor de arranque instalado: `sudo grub-install --version`.

9. **Permisos Básicos**
   - Cambia los permisos de un archivo: `chmod 644 practicaLinux/ejercicios/archivo1.txt`.
   - Cambia el propietario del archivo: `sudo chown usuario:grupo practicaLinux/ejercicios/archivo1.txt`.

## Actividades

### Actividad 1: Introducción al terminal de comandos
1. Investiga cómo abrir un terminal en tu sistema operativo y describe los pasos necesarios.
2. Identifica las partes del _prompt_ y explica su significado.
3. Ejecuta el comando `ls` en tu terminal y describe el resultado obtenido.

### Actividad 2: Estructura de directorios
1. Describe la diferencia entre el directorio raíz y el directorio personal del usuario.
2. Investiga y enumera los directorios principales que se encuentran en un sistema basado en Unix, explicando brevemente su función.
3. Utiliza el comando `pwd` para mostrar tu directorio actual y explica su utilidad.

### Actividad 3: Gestión de archivos
1. Investiga los diferentes tipos de archivos en Linux y proporciona ejemplos de cada uno.
2. Crea un archivo de texto en tu terminal y verifica su tipo utilizando el comando `file`.
3. Explica la importancia de la nomenclatura de archivos en Linux y menciona las reglas básicas para nombrarlos.

### Actividad 4: Permisos básicos
1. Investiga cómo se asignan los permisos a los archivos y directorios en Linux.
2. Utiliza el comando `ls -l` para listar los permisos de un archivo o directorio y explica su significado.
3. Describe los tres casos principales de permisos: propietario, grupo y otros.

### Actividad 5: Redirecciones
1. Investiga qué son las redirecciones en Linux y proporciona ejemplos de su uso.
2. Utiliza el comando `>` para redirigir la salida de un comando a un archivo y describe el resultado.
3. Explica la diferencia entre `>` y `>>` al redirigir salidas.

### Actividad 6: Filtros
1. Investiga qué son los filtros en Linux y menciona algunos comandos que actúan como filtros.
2. Utiliza el comando `grep` para buscar líneas específicas en un archivo y describe el resultado.
3. Explica la diferencia entre `grep` y `egrep`.

### Actividad 7: Búsqueda de archivos
1. Investiga el comando `find` y describe su uso general.
2. Utiliza el comando `find` para buscar archivos con una extensión específica en un directorio y describe el resultado.
3. Explica cómo se pueden combinar opciones en el comando `find` para realizar búsquedas más precisas.

### Entrega
- Realiza cada uno de los pasos y toma capturas de pantalla de los resultados.
- Entrega un archivo comprimido con las capturas y los archivos generados durante la práctica.
