---
search:
  exclude: true
---
## Soluciones: Linux

### Introducción
1. `pwd`
2. `ls`
3. `touch prueba.txt`

### Navegación y directorios
1. `cd /`
2. `mkdir nuevo_directorio`
3. `rmdir nuevo_directorio`

### Visualización de contenido
1. `cat /etc/passwd`
2. `wc -l prueba.txt`
3. `grep "root" /etc/passwd`

## Ejercicios avanzados

### Listado de archivos y directorios
1. `ls -la /`
2. `ls -laR /home`
3. `ls a*`

### Variables de entorno
1. `echo $HOME`
2. `echo $PATH`
3. `export PATH=$PATH:/nuevo/directorio`

### Gestión de directorios
1. `mkdir D1`
2. `cp * D1/`
3. `mv archivo.txt D1/`

### Permisos y propietarios
1. `chmod u+w archivo`
2. `sudo chown root archivo`
3. `chmod +x *.sh`

### Búsqueda y manipulación de archivos
1. `find $HOME -name "t*" -exec touch {} \;`
2. `find / -type f -user root -size -1M > ficheros_pequeños`
3. `find /home/guest -type f -size +5000M -writable -exec rm {} \;`

### Procesamiento de contenido
1. `cat /etc/passwd | tr ':' '_'`
2. `grep "^root" /etc/passwd`
3. `grep "bash" /etc/passwd | wc -l`

### Redirecciones
1. `sudo cat /etc/shadow >> salida.txt 2>> errores.txt`
2. `tail -n 3 t1 > resultado.txt`
3. `ls > listado.txt 2> errores_listado.txt`
