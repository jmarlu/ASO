# Actividades: preparar un informe de administración

## Objetivo y condiciones

Repasar la terminal antes de comenzar scripting. Utiliza Bash, una cuenta sin privilegios y la [zona de práctica](index.md#preparar-las-practicas). El conjunto de datos es ficticio y está incluido: no necesitas Moodle ni servicios externos. Conserva los originales en `datos` y guarda las pruebas en `trabajo`, `salidas` y `evidencias`.

Puedes consultar `man`, `--help` y los apuntes. Si utilizas una orden adicional, explica su funcionamiento. Entrega comandos y resultados; no se exige una captura por cada tecla.

## Diagnóstico inicial — 15 minutos

Sin ayuda, intenta: mostrar el directorio actual, listar ocultos, copiar un archivo con espacios en su nombre, interpretar 640 y explicar `>` frente a `>>`. Anota dudas. Esta actividad decide cuánto repaso necesitas; no se califica como una práctica final.

## 1. Terminal y ayuda — 25 minutos

1. Registra `whoami`, `id`, `pwd` y la versión de Bash.
2. Localiza en la ayuda de `ls` qué hacen `-a`, `-l` y `-d`. Demuestra la diferencia entre listar `datos` y consultar el propio directorio.
3. Explica por qué `bash ls -l` no es la forma general de listar archivos.
4. Ejecuta `type cd` y `type ls` e interpreta la salida de tu máquina, incluidos posibles alias.

**Entrega:** `evidencias/01-terminal.md` con cuatro órdenes comentadas y la identidad real. El texto del prompt no basta para acreditar privilegios.

## 2. Rutas y archivos — 35 minutos

1. Desde la raíz de la práctica crea `trabajo/archivo`.
2. Copia `datos/servicios.txt` con el nombre `inventario inicial.txt` dentro de ese directorio.
3. Entra en `trabajo/archivo` y muestra el original mediante una ruta relativa; muestra después la copia con una ruta absoluta.
4. Renombra la copia como `inventario.txt`. Crea y elimina únicamente un archivo vacío de prueba.
5. Crea `trabajo/enlace-inventario` apuntando a `archivo/inventario.txt`. Explica desde dónde se interpreta el destino relativo del enlace.
6. Clasifica `/etc`, `/var/log`, `/proc`, `/srv` y `/root` por función. Consúltalos sin modificar su contenido.

**Entrega:** árbol final mediante `find trabajo -maxdepth 3 -print`, comandos y explicación de dos rutas. Comprueba que la copia tiene el mismo contenido que el original.

## 3. Permisos y denegaciones — 45 minutos

```bash
cp datos/servicios.txt trabajo/permisos.txt
chmod 640 trabajo/permisos.txt
stat -c '%a %U %G %n' trabajo/permisos.txt
chmod 000 trabajo/permisos.txt
cat trabajo/permisos.txt
printf 'Código de cat: %s\n' "$?"
chmod 600 trabajo/permisos.txt
cat trabajo/permisos.txt
```

1. Explica la denegación y la recuperación. Ejecuta las órdenes individualmente para observar el fallo y poder restaurar los permisos.
2. Crea archivos y directorios nuevos con umask 077 dentro de una subshell; verifica 600 y 700. Comprueba que la máscara de tu terminal no cambia.
3. Explica por qué 750 permite ejecutar al grupo.
4. Demuestra que un archivo con modo 400 puede eliminarse si tienes permisos adecuados en su directorio. Usa exclusivamente este caso de prueba:

```bash
mkdir trabajo/borrado-controlado
printf 'Solo prueba\n' > trabajo/borrado-controlado/solo-lectura.txt
chmod 400 trabajo/borrado-controlado/solo-lectura.txt
rm -i -- trabajo/borrado-controlado/solo-lectura.txt
rmdir trabajo/borrado-controlado
```

Confirma el borrado cuando se solicite. No confundas que `rm` pida confirmación con una denegación del sistema de archivos.

**Entrega:** modos antes/después, error y código de salida, explicación de permisos del archivo frente al directorio. No uses sudo ni chmod 777.

## 4. Redirecciones — 40 minutos

1. Guarda la fecha y añade la identidad de usuario en `salidas/sesion.txt` sin borrar la fecha.
2. Ejecuta una orden `ls -ld` que consulte `datos` y una ruta inexistente. Separa stdout en `salidas/listado.txt` y stderr en `salidas/errores.txt`.
3. Repite guardando ambos canales en `salidas/juntos.txt`.
4. Invierte el orden de `> archivo` y `2>&1`. Explica qué llega al archivo y qué sigue apareciendo en pantalla.
5. Cuenta líneas del inventario mediante entrada redirigida.

**Entrega:** archivos producidos y explicación del orden de procesamiento. El fallo de `ls` en estas pruebas es intencionado.

## 5. Filtros — 45 minutos

Usa los datos originales sin modificarlos:

1. Genera `salidas/fallidos.txt` con los equipos cuyo campo de estado es `fallido`.
2. Obtén solo los nombres de esos equipos, uno por línea.
3. Ordena el inventario por memoria de mayor a menor.
4. Cuenta equipos por servicio, agrupando las repeticiones aunque no sean consecutivas en el original.
5. Obtén las líneas ERROR de `eventos.log` y cuenta errores por equipo.
6. Explica por qué buscar `activo` sin delimitadores podría incluir `inactivo` en otro inventario.
7. Compara `wc -c` y `wc -m` en un archivo que contenga una palabra acentuada; registra la localización de tu terminal con `locale`.

**Comprobaciones:** hay seis equipos, dos con estado fallido, tres eventos ERROR y dos equipos distintos con errores. `files01` encabeza la ordenación por memoria. Un resultado correcto debe poder obtenerse de nuevo desde los datos, no escribirse a mano.

## 6. Búsquedas — 35 minutos

Prepara estas entradas aisladas:

```bash
mkdir trabajo/busquedas
touch trabajo/busquedas/actual.txt trabajo/busquedas/antiguo.log trabajo/busquedas/ejecutable.sh
printf '1234567890' > trabajo/busquedas/diez.bin
chmod 700 trabajo/busquedas/ejecutable.sh
touch -d '180 minutes ago' trabajo/busquedas/antiguo.log
```

1. Localiza los archivos regulares terminados en `.txt` o `.log`, agrupando la alternativa.
2. Busca los que tienen ejecución para el propietario, independientemente del resto de bits.
3. Localiza exactamente diez bytes.
4. Busca una antigüedad de modificación comprendida entre más de 120 y menos de 300 minutos completos. Ejecuta esta prueba en la sesión en que preparaste los datos.
5. Cuenta las líneas de los `.txt` mediante `find -exec wc -l`.
6. Explica por qué `-mtime -2 -mtime +5` es imposible, qué representa ctime y por qué `-size 100k` no significa tamaño exacto de 102400 bytes.

**Entrega:** expresiones y resultados. No ejecutes búsquedas que modifiquen archivos del sistema.

## 7. Práctica integrada — 60 minutos

Eres responsable de revisar el inventario del aula. Genera `salidas/informe-aula.txt` mediante órdenes agrupadas y filtros, con estas secciones:

- Fecha e identidad de quien genera el informe.
- Número total de equipos.
- Nombres de equipos fallidos.
- Inventario ordenado por memoria descendente.
- Número de equipos por servicio.
- Recuento de errores por equipo.

El informe debe calcularse desde los datos; no copies los números esperados como texto. Dale modo 600 y verifica propietario y permisos. Conserva la secuencia de órdenes en `evidencias/ordenes-informe.txt` y ejecútala de nuevo para demostrar que se regenera sin duplicar secciones.

**Puente a scripting:** en la siguiente parte de UD1 esta secuencia se convertirá en un archivo `.sh` con shebang, parámetros y validaciones. Aquí no se requieren bucles, funciones ni tareas programadas.

## Entrega y valoración

Entrega una carpeta con `datos`, `salidas` y `evidencias`. `trabajo` puede conservarse para demostrar pruebas, pero no hace falta entregar archivos ajenos al ejercicio ni el historial completo de tu terminal.

| Apartado | Peso |
|---|---:|
| Terminal, ayuda, rutas y archivos | 20 % |
| Permisos y recuperación | 20 % |
| Redirecciones y explicación de canales | 20 % |
| Filtros y búsquedas | 25 % |
| Informe reproducible y documentación | 15 % |

En cada apartado: 0 si falta o es incorrecto; mitad del peso si funciona parcialmente pero falta una comprobación; peso completo si funciona y se explica. Es una rúbrica de repaso, no una nueva ponderación de resultados de aprendizaje del módulo.

La secuencia completa ocupa unas cinco horas. Si el diagnóstico demuestra dominio, el docente puede reducir ejercicios repetidos y mantener las pruebas de permisos, redirecciones y el informe. Este tiempo debe reservarse dentro de la planificación de UD1.
