# Scripts de refuerzo muy basicos (UD1 Linux)

Este set contiene ejercicios rapidos para practicar los mismos conceptos que se trabajan en Actividades y en la hoja de comandos.

## Resumen rapido

| Script | Idea principal | Actividades relacionadas | Comandos claves |
| --- | --- | --- | --- |
| `refuerzo_01_saludo.sh` | Lectura por teclado y comandos informativos. | Introduccion 1 y 2. | `read`, `date`, `pwd`, `whoami` |
| `refuerzo_02_prepara_entorno.sh` | Crear directorios y ficheros de practica. | Introduccion 1. | `mkdir`, `touch`, `ls` |
| `refuerzo_03_info_usuario.sh` | Argumentos y consulta de cuentas. | Argumentos 2. | `getent`, `cut`, `whoami` |
| `refuerzo_04_paridad.sh` | Condicional IF y aritmetica. | IF 1. | `read`, `[[ ]]`, `(( ))` |
| `refuerzo_05_menu_basico.sh` | Menu con while + case. | IF 4 y Case/While 1. | `while`, `case`, `date`, `ls`, `df` |
| `refuerzo_06_contar_txt.sh` | Bucle for sobre ficheros. | For 3. | `for`, `wc -l`, `basename` |
| `refuerzo_07_permisos_scripts.sh` | Recorrido for-in y `chmod`. | For-in 1. | `chmod`, `ls` |

## Detalle de cada guion

### `refuerzo_01_saludo.sh`
- **Objetivo**: pedir el nombre, recordar donde esta el usuario y mostrar fecha/hora.
- **Uso**: `./refuerzo_01_saludo.sh` y escribir un nombre (se usa uno generico si se deja vacio).
- **Refuerzo**: actividades iniciales de creacion de scripts y comandos `pwd`/`ls`/`date`.

### `refuerzo_02_prepara_entorno.sh`
- **Objetivo**: automatizar la carpeta `~/practicas_linux` (o el nombre que indique el alumno), crear `notas.txt` y listar el resultado.
- **Uso**: `./refuerzo_02_prepara_entorno.sh` y aceptar o cambiar el nombre sugerido.
- **Refuerzo**: coincide con la actividad 1 (preparar rutas y permisos) y repasa `mkdir`, `touch`, `ls -lha`.

### `refuerzo_03_info_usuario.sh`
- **Objetivo**: aceptar un usuario como argumento (por defecto el actual) y mostrar su HOME y shell por defecto.
- **Uso**: `./refuerzo_03_info_usuario.sh` o `./refuerzo_03_info_usuario.sh alumno01`.
- **Refuerzo**: actividad `scriptArgs_3.sh` (consulta de datos del usuario) y comandos `getent`, `cut` y `whoami`.

### `refuerzo_04_paridad.sh`
- **Objetivo**: validar que la entrada sea un entero y decir si es par o impar.
- **Uso**: `./refuerzo_04_paridad.sh` e introducir un numero (controla errores si no es entero).
- **Refuerzo**: actividad `Script_IF_1.sh` con una version muy corta.

### `refuerzo_05_menu_basico.sh`
- **Objetivo**: practicar un bucle `while` con `case` y tres comandos utiles (`date`, `pwd`/`ls` y `df`).
- **Uso**: `./refuerzo_05_menu_basico.sh` y elegir opciones 1-4 hasta salir.
- **Refuerzo**: menu de redes (`Script_IF_4.sh`) pero simplificado y sin dependencias externas.

### `refuerzo_06_contar_txt.sh`
- **Objetivo**: recibir un directorio, localizar sus `.txt` con `find` y mostrar cuantas lineas tiene cada uno (o avisar si no existen).
- **Uso**: `./refuerzo_06_contar_txt.sh ruta/opcional`. Si no hay directorio se usa el actual.
- **Refuerzo**: tabla de asteriscos / practicas con `for (( ))` y `for in`; repasa `find` para obtener listados simples de ficheros.

### `refuerzo_07_permisos_scripts.sh`
- **Objetivo**: recorrer los `.sh` de un directorio y asegurar que el grupo pueda ejecutar (`chmod g+x`), mostrando `ls -l` de cada fichero modificado.
- **Uso**: `./refuerzo_07_permisos_scripts.sh ruta/opcional`. Si no hay scripts, informa y termina.
- **Refuerzo**: actividad de permisos para el grupo en la seccion For-in.

## Recomendaciones para el examen

1. Copiar los scripts al directorio personal del alumno (`~/misScripts`) y ejecutar con `./nombre.sh` o añadir ese directorio al PATH y ejecutar con `nombre.sh`.
2. Modificar spripts : cambiar mensajes, anadir nuevas opciones o reutilizar fragmentos en las actividades que hemos realizado en casa.
3. Registrar dudas o errores encontrados para preguntarme: todos los scripts son cortos para centrarse en el concepto basico.
