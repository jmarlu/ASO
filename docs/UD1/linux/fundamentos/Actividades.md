# Actividades: preparar un informe de administración

## Objetivo y condiciones

Repasar la terminal antes de comenzar scripting. Utiliza Bash, una cuenta sin privilegios y la [zona de práctica](index.md#preparar-las-practicas). El conjunto de datos es ficticio y está incluido: no necesitas Moodle ni servicios externos. Conserva los originales en `datos` y guarda las pruebas en `trabajo`, `salidas` y `evidencias`.

Puedes consultar `man`, `--help` y los apuntes. Si utilizas una orden adicional, explica su funcionamiento. Entrega comandos y resultados; no se exige una captura por cada tecla.

## Cómo organizar el trabajo

**Todos los ejercicios de esta página son obligatorios**, incluidos los bloques de comandos y los ejercicios numerados de cada tema. Debes ejecutar y explicar los comandos propuestos, resolver los enunciados y entregar las evidencias indicadas.

Comienza cada bloque desde la raíz de la zona de práctica y ejecuta cada preparación una sola vez; para repetir todo, crea una zona nueva. El profesorado comunicará los plazos de entrega.

Usa `echo` para los mensajes; `printf` queda como alternativa cuando necesites controlar el formato. Intenta resolver los retos sin copiar una solución y explica los comandos que utilices.

## Diagnóstico inicial

Sin ayuda, intenta: mostrar el directorio actual, listar ocultos, copiar un archivo con espacios en su nombre, interpretar 640 y explicar `>` frente a `>>`. Anota dudas. Esta actividad decide cuánto repaso necesitas; no se califica como una práctica final.

## 1. Terminal y ayuda

1. Registra `whoami`, `id`, `pwd` y la versión de Bash.
2. Localiza en la ayuda de `ls` qué hacen `-a`, `-l` y `-d`. Demuestra la diferencia entre listar `datos` y consultar el propio directorio.
3. Explica por qué `bash ls -l` no es la forma general de listar archivos.
4. Ejecuta `type cd` y `type ls` e interpreta la salida de tu máquina, incluidos posibles alias.
5. Identifica el emulador de terminal utilizado, la shell configurada y la shell de la sesión actual. Explica la diferencia.
6. Comprueba a qué programa apunta `/bin/sh`. Elige dos shells de la tabla de teoría y compara una característica de cada una con Bash. No cambies tu shell de inicio de sesión.

**Entrega:** `evidencias/01-terminal.md` con las órdenes comentadas, la identidad real y la comparación de shells. El texto del prompt no basta para acreditar privilegios.

### Práctica obligatoria de terminal y ayuda

#### Paso 1. Ejecuta y explica cada comando

Ejecuta las órdenes una a una desde la raíz de la práctica. **Debes explicar cada comando por separado**, con tus propias palabras. Para cada uno, registra en las evidencias del tema:

- El comando ejecutado y su finalidad.
- El significado de sus opciones y argumentos.
- Cómo funcionan las tuberías o redirecciones, si las hay.
- El resultado obtenido y por qué se produce, incluidos los errores previstos.

En los bloques entre paréntesis o llaves, explica también cada orden interior y la función de la agrupación. Una captura o una copia de la salida sin explicación no completa la actividad.

Ejecuta desde la raíz de la práctica:

```bash
help echo > evidencias/ayuda-echo.txt
command -v bash ls grep find
bash --version | head -n 1
history 10
echo 'El directorio personal es $HOME'
echo "El directorio personal es $HOME"
echo -n 'ASO' > trabajo/sin-salto.txt
echo 'ASO' > trabajo/con-salto.txt
wc -c trabajo/sin-salto.txt trabajo/con-salto.txt
```

#### Paso 2. Resuelve los ejercicios obligatorios

Resuelve los enunciados utilizando lo que has practicado. Guarda el comando, el resultado y una explicación breve; puedes consultar los ejemplos y adaptarlos.

1. Explica por qué las dos órdenes con `$HOME` producen textos diferentes.
2. Consulta `help echo`: identifica la opción que omite el salto de línea. Comprueba que los archivos tienen 3 y 4 bytes respectivamente.
3. Ejecuta `type -a echo` y distingue la orden interna de los ejecutables que encuentre tu máquina.
4. Busca en `man ls` la palabra `directory`, repite la búsqueda con `n` y sal con `q`. Si no hay manuales instalados, usa `ls --help`.
5. Ejecuta `cat trabajo/no-existe-terminal.txt` y, justo después, `echo $?`. Repite con `cat trabajo/con-salto.txt`. Anota ambos estados.
6. Recupera una orden anterior con la flecha arriba, edítala y ejecútala. No entregues el historial completo: puede contener información ajena a la práctica.
7. Ejecuta `false && echo 'segunda orden'` y `false || echo 'alternativa'`. Explica cuál muestra texto y por qué. `false` es una orden que devuelve un estado de fallo intencionado.
8. Obtén la ayuda de `pwd` y compara `pwd -L` con `pwd -P`: anota en qué situación pueden diferir.

**Comprobación:** los mensajes y tamaños son reproducibles; las rutas de ejecutables, versión e historial dependen de tu equipo. Añade la explicación a `evidencias/01-terminal.md`.

## 2. Rutas y archivos

1. Desde la raíz de la práctica crea `trabajo/archivo`.
2. Copia `datos/servicios.txt` con el nombre `inventario inicial.txt` dentro de ese directorio.
3. Entra en `trabajo/archivo` y muestra el original mediante una ruta relativa; muestra después la copia con una ruta absoluta.
4. Renombra la copia como `inventario.txt`. Crea y elimina únicamente un archivo vacío de prueba.
5. Crea `trabajo/enlace-inventario` apuntando a `archivo/inventario.txt`. Explica desde dónde se interpreta el destino relativo del enlace.
6. Clasifica `/etc`, `/var/log`, `/proc`, `/srv` y `/root` por función. Consúltalos sin modificar su contenido.

**Entrega:** árbol final mediante `find trabajo -maxdepth 3 -print`, comandos y explicación de dos rutas. Comprueba que la copia tiene el mismo contenido que el original.

### Práctica obligatoria de rutas, copias y enlaces

#### Paso 1. Ejecuta y explica cada comando

Ejecuta las órdenes una a una desde la raíz de la práctica. **Debes explicar cada comando por separado**, con tus propias palabras. Para cada uno, registra en las evidencias del tema:

- El comando ejecutado y su finalidad.
- El significado de sus opciones y argumentos.
- Cómo funcionan las tuberías o redirecciones, si las hay.
- El resultado obtenido y por qué se produce, incluidos los errores previstos.

En los bloques entre paréntesis o llaves, explica también cada orden interior y la función de la agrupación. Una captura o una copia de la salida sin explicación no completa la actividad.

Comienza en la raíz de la práctica. Los paréntesis permiten cambiar de directorio dentro de una subshell y volver automáticamente al terminar:

```bash
mkdir -p trabajo/rutas/proyecto/documentos trabajo/rutas/proyecto/copias
cp -- datos/servicios.txt 'trabajo/rutas/proyecto/documentos/inventario aula.txt'
(
    cd trabajo/rutas/proyecto/documentos || exit
    pwd
    realpath 'inventario aula.txt'
    cat ../../../../datos/servicios.txt
    cd ..
    ls -ld documentos copias
)
cmp -- datos/servicios.txt 'trabajo/rutas/proyecto/documentos/inventario aula.txt'
echo "Estado de la comparación: $?"
cp -a -- trabajo/rutas/proyecto/documentos trabajo/rutas/proyecto/copias/documentos-respaldo
ln -s -- 'documentos/inventario aula.txt' trabajo/rutas/proyecto/enlace-inventario
readlink trabajo/rutas/proyecto/enlace-inventario
```

#### Paso 2. Resuelve los ejercicios obligatorios

Resuelve los enunciados utilizando lo que has practicado. Guarda el comando, el resultado y una explicación breve; puedes consultar los ejemplos y adaptarlos.

1. Dibuja la ruta recorrida por los cuatro `..`. Comprueba que el `pwd` de tu terminal no ha cambiado al finalizar el bloque.
2. Renombra la copia original a `inventario.txt` mediante `mv`. Intenta leer el enlace: registra por qué falla aunque siga apareciendo en `ls -l`.
3. Elimina solo el enlace con `rm -i -- trabajo/rutas/proyecto/enlace-inventario` y créalo de nuevo apuntando a `documentos/inventario.txt`. Comprueba que el archivo de destino sigue existiendo.
4. Crea `trabajo/rutas/.nota` y compara `ls trabajo/rutas` con `ls -la trabajo/rutas`. Explica por qué oculto no significa protegido.
5. Crea un archivo llamado `-nota.txt` dentro de `trabajo/rutas`, utilizando `touch -- trabajo/rutas/-nota.txt`. Muéstralo y elimínalo sin que su nombre se interprete como una opción.
6. Crea `trabajo/rutas/vacio`, elimínalo con `rmdir` e intenta después `rmdir trabajo/rutas/proyecto`. Explica la diferencia de resultados.
7. Consulta `ls -ld / /root /tmp /proc /sys /dev` y `findmnt -T .`. Identifica la raíz, el directorio personal del administrador y dos interfaces virtuales.
8. Usa `file` y `stat` sobre `inventario.txt`. Distingue formato del contenido, tamaño, propietario y tipo de entrada.

**Comprobación:** `cmp` no muestra diferencias y devuelve 0 antes del renombrado. El respaldo conserva seis líneas. El enlace reparado permite leerlas. Guarda órdenes y resultados en `evidencias/02-rutas.md`.

## 3. Permisos y denegaciones

```bash
cp datos/servicios.txt trabajo/permisos.txt
chmod 640 trabajo/permisos.txt
stat -c '%a %U %G %n' trabajo/permisos.txt
chmod 000 trabajo/permisos.txt
cat trabajo/permisos.txt
echo "Código de cat: $?"
chmod 600 trabajo/permisos.txt
cat trabajo/permisos.txt
```

1. Explica la denegación y la recuperación. Ejecuta las órdenes individualmente para observar el fallo y poder restaurar los permisos.
2. Crea archivos y directorios nuevos con umask 077 dentro de una subshell; verifica 600 y 700. Comprueba que la máscara de tu terminal no cambia.
3. Explica por qué 750 permite ejecutar al grupo.
4. Demuestra que un archivo con modo 400 puede eliminarse si tienes permisos adecuados en su directorio. Usa exclusivamente este caso de prueba:

```bash
mkdir trabajo/borrado-controlado
echo 'Solo prueba' > trabajo/borrado-controlado/solo-lectura.txt
chmod 400 trabajo/borrado-controlado/solo-lectura.txt
rm -i -- trabajo/borrado-controlado/solo-lectura.txt
rmdir trabajo/borrado-controlado
```

Confirma el borrado cuando se solicite. No confundas que `rm` pida confirmación con una denegación del sistema de archivos.

**Entrega:** modos antes/después, error y código de salida, explicación de permisos del archivo frente al directorio. No uses sudo ni chmod 777.

### Práctica obligatoria de permisos de archivos y directorios

#### Paso 1. Ejecuta y explica cada comando

Ejecuta las órdenes una a una desde la raíz de la práctica. **Debes explicar cada comando por separado**, con tus propias palabras. Para cada uno, registra en las evidencias del tema:

- El comando ejecutado y su finalidad.
- El significado de sus opciones y argumentos.
- Cómo funcionan las tuberías o redirecciones, si las hay.
- El resultado obtenido y por qué se produce, incluidos los errores previstos.

En los bloques entre paréntesis o llaves, explica también cada orden interior y la función de la agrupación. Una captura o una copia de la salida sin explicación no completa la actividad.

```bash
cp datos/servicios.txt trabajo/permisos-practica.txt
chmod u=rw,g=r,o= trabajo/permisos-practica.txt
stat -c '%a %A %U %G %n' trabajo/permisos-practica.txt
chmod g-r trabajo/permisos-practica.txt
stat -c '%a %A %n' trabajo/permisos-practica.txt
chgrp "$(id -gn)" trabajo/permisos-practica.txt
mkdir -p trabajo/paso
chmod 700 trabajo/paso
echo 'Contenido conocido' > trabajo/paso/conocido.txt
chmod 600 trabajo/paso/conocido.txt
chmod 100 trabajo/paso
ls trabajo/paso
echo "Estado del listado: $?"
cat trabajo/paso/conocido.txt
chmod 700 trabajo/paso
```

Ejecuta individualmente las órdenes: el fallo de `ls` es parte de la prueba. Restaura siempre el directorio a 700 al terminar.

#### Paso 2. Resuelve los ejercicios obligatorios

Resuelve los enunciados utilizando lo que has practicado. Guarda el comando, el resultado y una explicación breve; puedes consultar los ejemplos y adaptarlos.

1. Explica los cambios 640 → 600 y escribe una orden numérica equivalente a cada `chmod` simbólico.
2. Justifica por qué puedes leer `conocido.txt` sin poder listar su directorio: ya conoces el nombre y tienes permiso de paso.
3. Cambia el directorio a 600, intenta leer el archivo y restaura 700. Explica qué permiso falta ahora.
4. Registra `umask`, crea un archivo y un directorio nuevos en una subshell con máscara 027 y comprueba 640 y 750. Usa los nombres `trabajo/mascara027.txt` y `trabajo/mascara027-dir`; no reutilices entradas existentes.
5. Compara esos resultados con la prueba de máscara 077 y verifica que la máscara de la sesión principal no cambia.
6. Aplica 640 a un archivo propio y usa `chmod u+x`: predice y verifica el modo resultante. Después restaura 640.
7. Explica por qué añadir `x` a un archivo de texto no lo convierte automáticamente en un programa válido.
8. Consulta el propietario y grupo con `ls -l`, `ls -ln` y `stat`. Relaciona los nombres con los identificadores de `id`.

**Comprobación:** en el modelo básico del laboratorio, el listado sin `r` falla y la lectura por nombre con `x` funciona. `640` más ejecución del propietario produce `740`. No utilices root ni cambies propietarios. Documenta en `evidencias/03-permisos.md`.

## 4. Redirecciones

1. Guarda la fecha y añade la identidad de usuario en `salidas/sesion.txt` sin borrar la fecha.
2. Ejecuta una orden `ls -ld` que consulte `datos` y una ruta inexistente. Separa stdout en `salidas/listado.txt` y stderr en `salidas/errores.txt`.
3. Repite guardando ambos canales en `salidas/juntos.txt`.
4. Invierte el orden de `> archivo` y `2>&1`. Explica qué llega al archivo y qué sigue apareciendo en pantalla.
5. Cuenta líneas del inventario mediante entrada redirigida.

**Entrega:** archivos producidos y explicación del orden de procesamiento. El fallo de `ls` en estas pruebas es intencionado.

### Práctica obligatoria de entrada, salida y tuberías

#### Paso 1. Ejecuta y explica cada comando

Ejecuta las órdenes una a una desde la raíz de la práctica. **Debes explicar cada comando por separado**, con tus propias palabras. Para cada uno, registra en las evidencias del tema:

- El comando ejecutado y su finalidad.
- El significado de sus opciones y argumentos.
- Cómo funcionan las tuberías o redirecciones, si las hay.
- El resultado obtenido y por qué se produce, incluidos los errores previstos.

En los bloques entre paréntesis o llaves, explica también cada orden interior y la función de la agrupación. Una captura o una copia de la salida sin explicación no completa la actividad.

```bash
echo 'Primera línea' > trabajo/canales.txt
echo 'Segunda línea' >> trabajo/canales.txt
cat -n trabajo/canales.txt
wc -l < trabajo/canales.txt
cp trabajo/canales.txt trabajo/canales-copia.txt
echo 'Contenido nuevo' > trabajo/canales-copia.txt
wc -l trabajo/canales.txt trabajo/canales-copia.txt
cat < datos/servicios.txt > salidas/inventario-redirigido.txt
cmp datos/servicios.txt salidas/inventario-redirigido.txt
grep ';fallido;' datos/servicios.txt | tee salidas/fallidos-tee.txt | wc -l
```

#### Paso 2. Resuelve los ejercicios obligatorios

Resuelve los enunciados utilizando lo que has practicado. Guarda el comando, el resultado y una explicación breve; puedes consultar los ejemplos y adaptarlos.

1. Explica por qué la copia tiene una línea y el archivo inicial conserva dos.
2. Sustituye `tee` por `tee -a`, repite la última tubería y compara el número de líneas de su salida con el archivo acumulado. Antes de la siguiente actividad, regenera el archivo con `tee` sin `-a`.
3. Redirige solo el error de una ruta inexistente a `salidas/error-practica.txt`. Conserva el código de salida inmediatamente mediante `echo $?`.
4. Envía a `/dev/null` únicamente la salida normal de `ls -ld datos ruta-inexistente`. Explica por qué el error sigue apareciendo.
5. Agrupa `echo 'Resumen'`, `date` y `id` entre llaves y guarda todo en `salidas/resumen-sesion.txt`.
6. Explica por qué `cat datos/servicios.txt > datos/servicios.txt` destruiría el contenido antes de leerlo. No lo ejecutes sobre los datos originales.
7. Genera un mensaje con `echo 'Aviso de prueba' >&2` y redirige el error del grupo a un archivo. Comprueba que la salida normal queda vacía.
8. Compara `grep ';fallido;' datos/servicios.txt | wc -l` con `grep -c ';fallido;' datos/servicios.txt`.

**Comprobación:** ambas cuentas de fallidos dan 2. Con `tee -a`, la tubería sigue contando las dos filas recién recibidas, pero el archivo acumula cuatro tras la primera repetición. Guarda la explicación en `evidencias/04-canales.md`.

## 5. Filtros

Usa los datos originales sin modificarlos:

1. Genera `salidas/fallidos.txt` con los equipos cuyo campo de estado es `fallido`.
2. Obtén solo los nombres de esos equipos, uno por línea.
3. Ordena el inventario por memoria de mayor a menor.
4. Cuenta equipos por servicio, agrupando las repeticiones aunque no sean consecutivas en el original.
5. Obtén las líneas ERROR de `eventos.log` y cuenta errores por equipo.
6. Explica por qué buscar `activo` sin delimitadores podría incluir `inactivo` en otro inventario.
7. Compara `wc -c` y `wc -m` en un archivo que contenga una palabra acentuada; registra la localización de tu terminal con `locale`.

**Comprobaciones:** hay seis equipos, dos con estado fallido, tres eventos ERROR y dos equipos distintos con errores. `files01` encabeza la ordenación por memoria. Un resultado correcto debe poder obtenerse de nuevo desde los datos, no escribirse a mano.

### Práctica obligatoria de filtros y expresiones regulares

#### Paso 1. Ejecuta y explica cada comando

Ejecuta las órdenes una a una desde la raíz de la práctica. **Debes explicar cada comando por separado**, con tus propias palabras. Para cada uno, registra en las evidencias del tema:

- El comando ejecutado y su finalidad.
- El significado de sus opciones y argumentos.
- Cómo funcionan las tuberías o redirecciones, si las hay.
- El resultado obtenido y por qué se produce, incluidos los errores previstos.

En los bloques entre paréntesis o llaves, explica también cada orden interior y la función de la agrupación. Una captura o una copia de la salida sin explicación no completa la actividad.

```bash
head -n 3 datos/servicios.txt
tail -n 2 datos/eventos.log
cut -d';' -f1,2 datos/servicios.txt
cut -d';' -f2 datos/servicios.txt | LC_ALL=C sort -u
grep -En '^web[0-9]{2};' datos/servicios.txt
grep -Ec ' (ERROR|WARN) ' datos/eventos.log
grep -E ';[0-9]{3}$' datos/servicios.txt
cut -d';' -f1 datos/servicios.txt | tr '[:lower:]' '[:upper:]'
```


#### Paso 2. Resuelve los ejercicios obligatorios

Resuelve los enunciados utilizando lo que has practicado. Guarda el comando, el resultado y una explicación breve; puedes consultar los ejemplos y adaptarlos.

1. Guarda los equipos activos en `salidas/activos.txt`, seleccionando el campo completo; deben aparecer cuatro filas.
2. Obtén los nombres de servicios sin duplicados: cron, nginx, slapd y smbd, ordenados alfabéticamente.
3. Ordena el inventario por memoria ascendente y comprueba los extremos: web03 y files01.
4. Muestra las líneas del registro que no son ERROR ni WARN. Cuenta tres INFO.
5. Extrae con `grep -Eo` los nombres web seguidos de dos dígitos y cuenta las apariciones de cada equipo usando `sort` y `uniq -c`.
6. Selecciona nombres de equipo que empiecen por web o ldap. Utiliza agrupación para que `^` se aplique a ambas alternativas.
7. Crea `trabajo/estados.txt` con tres líneas mediante `echo`: `activo`, `inactivo`, `activo`. Compara `grep 'activo'`, `grep -x 'activo'` y `grep -c '^activo$'`.
8. Añade una línea vacía con `echo` y localízala con `grep -n '^$'`. Después utiliza `grep -v '^$'` para obtener un archivo sin líneas vacías.
9. Genera `trabajo/espacios.txt` con `echo 'uno   dos    tres'`; comprime los espacios con `tr -s ' '` y guárdalo en otro archivo.
10. Escribe `echo -n 'á' > trabajo/acento.txt`. Compara bytes y caracteres: en una sesión UTF-8 se esperan 2 bytes y 1 carácter. Si no ocurre, revisa `locale`.
11. Practica `*`, `+`, `?`, `{2}` y `{1,3}` con los [ejemplos de expresiones regulares](filtros.md#expresiones-regulares-paso-a-paso). Documenta una coincidencia y un rechazo de cada patrón.
12. Explica por qué `grep -F '.txt'` busca un punto literal y `grep '.txt'` también puede coincidir con `Xtxt`.

**Comprobación:** web01, web02 y web03 ocupan las líneas 1, 2 y 6 del inventario. Hay cinco eventos ERROR/WARN; las memorias de tres cifras corresponden a web01 y files01. En `estados.txt`, la búsqueda sin anclas selecciona tres líneas y la exacta solo dos. Guarda resultados en `evidencias/05-filtros.md`.

## 6. Búsquedas

Prepara estas entradas aisladas:

```bash
mkdir trabajo/busquedas
touch trabajo/busquedas/actual.txt trabajo/busquedas/antiguo.log trabajo/busquedas/ejecutable.sh
echo -n '1234567890' > trabajo/busquedas/diez.bin
chmod 700 trabajo/busquedas/ejecutable.sh
touch -d '180 minutes ago' trabajo/busquedas/antiguo.log
```

`echo -n` evita añadir un salto de línea: así `diez.bin` contiene exactamente diez bytes.

1. Localiza los archivos regulares terminados en `.txt` o `.log`, agrupando la alternativa.
2. Busca los que tienen ejecución para el propietario, independientemente del resto de bits.
3. Localiza exactamente diez bytes.
4. Busca una antigüedad de modificación comprendida entre más de 120 y menos de 300 minutos completos. Ejecuta esta prueba en la sesión en que preparaste los datos.
5. Cuenta las líneas de los `.txt` mediante `find -exec wc -l`.
6. Explica por qué `-mtime -2 -mtime +5` es imposible, qué representa ctime y por qué `-size 100k` no significa tamaño exacto de 102400 bytes.

**Entrega:** expresiones y resultados. No ejecutes búsquedas que modifiquen archivos del sistema.

### Práctica obligatoria de búsquedas combinadas

#### Paso 1. Ejecuta y explica cada comando

Ejecuta las órdenes una a una desde la raíz de la práctica. **Debes explicar cada comando por separado**, con tus propias palabras. Para cada uno, registra en las evidencias del tema:

- El comando ejecutado y su finalidad.
- El significado de sus opciones y argumentos.
- Cómo funcionan las tuberías o redirecciones, si las hay.
- El resultado obtenido y por qué se produce, incluidos los errores previstos.

En los bloques entre paréntesis o llaves, explica también cada orden interior y la función de la agrupación. Una captura o una copia de la salida sin explicación no completa la actividad.

Prepara este conjunto de archivos sin alterar los de la actividad anterior:

```bash
mkdir -p trabajo/busquedas-extra/subdirectorio
: > trabajo/busquedas-extra/vacio.txt
echo 'Una línea' > 'trabajo/busquedas-extra/informe aula.txt'
echo 'Registro' > trabajo/busquedas-extra/AVISO.LOG
echo 'Detalle' > trabajo/busquedas-extra/subdirectorio/detalle.log
echo -n '1234567890' > trabajo/busquedas-extra/diez.bin
chmod 640 'trabajo/busquedas-extra/informe aula.txt'
ln -s -- 'informe aula.txt' trabajo/busquedas-extra/enlace-informe
find trabajo/busquedas-extra -maxdepth 1 -type f -print
find trabajo/busquedas-extra -type f -iname '*.log' -print
find trabajo/busquedas-extra -type l -print
find trabajo/busquedas-extra -type f -empty -print
```

`:` es una orden interna que no realiza ninguna operación; la redirección crea o vacía el archivo de prueba. En estos nombres controlados no hay saltos de línea.

#### Paso 2. Resuelve los ejercicios obligatorios

Resuelve los enunciados utilizando lo que has practicado. Guarda el comando, el resultado y una explicación breve; puedes consultar los ejemplos y adaptarlos.

1. Compara `-name '*.log'` con `-iname '*.log'`: explica la diferencia con `AVISO.LOG`.
2. Localiza los archivos de tamaño exacto 10 bytes: se espera solo `diez.bin`. Comprueba con `wc -c` que «Una línea» en UTF-8 ocupa diez bytes más el salto de línea, es decir, 11 bytes.
3. Busca exclusivamente directorios y después exclusivamente enlaces, sin seguirlos. Explica por qué el enlace no aparece con `-type f` usando el comportamiento predeterminado.
4. Localiza archivos cuyo modo sea exactamente 640. Comprueba cada resultado con `stat`; pueden aparecer otros archivos según la máscara de creación de tu sesión.
5. Busca archivos pertenecientes a tu usuario con `-user "$(id -un)"`.
6. Combina `-type f` con nombres `.txt` o `.log`, agrupando correctamente las alternativas y sin distinguir mayúsculas.
7. Ejecuta `wc -l` mediante `-exec` sobre todos los `.txt`. Verifica que el nombre con espacios llega como un único argumento.
8. Repite con `-exec wc -l -- {} +` y compara las invocaciones y la posible línea de total.
9. Cuenta los archivos regulares con `find ... -type f -print | wc -l`: se esperan cinco para este conjunto de nombres controlados.
10. Obtén un listado ordenado de las rutas con `LC_ALL=C sort` y guárdalo en `salidas/busquedas-extra.txt`.

**Comprobación:** hay dos `.log` ignorando mayúsculas, un enlace, un archivo vacío y cinco archivos regulares. Documenta los comandos en `evidencias/06-busquedas.md`. No utilices `-delete` ni acciones de borrado masivo.

## 7. Práctica integrada

Eres responsable de revisar el inventario del aula. Genera `salidas/informe-aula.txt` mediante órdenes agrupadas y filtros, con estas secciones:

- Fecha e identidad de quien genera el informe.
- Número total de equipos.
- Nombres de equipos fallidos.
- Inventario ordenado por memoria descendente.
- Número de equipos por servicio.
- Recuento de errores por equipo.

El informe debe calcularse desde los datos; no copies los números esperados como texto. Dale modo 600 y verifica propietario y permisos. Conserva la secuencia de órdenes en `evidencias/ordenes-informe.txt` y ejecútala de nuevo para demostrar que se regenera sin duplicar secciones.

**Puente a scripting:** en la siguiente parte de UD1 esta secuencia se convertirá en un archivo `.sh` con shebang, parámetros y validaciones. Aquí no se requieren bucles, funciones ni tareas programadas.

### Informe obligatorio: comandos encadenados

#### Paso 1. Ejecuta y explica cada comando

Ejecuta las órdenes una a una desde la raíz de la práctica. **Debes explicar cada comando por separado**, con tus propias palabras. Para cada uno, registra en las evidencias del tema:

- El comando ejecutado y su finalidad.
- El significado de sus opciones y argumentos.
- Cómo funcionan las tuberías o redirecciones, si las hay.
- El resultado obtenido y por qué se produce, incluidos los errores previstos.

En los bloques entre paréntesis o llaves, explica también cada orden interior y la función de la agrupación. Una captura o una copia de la salida sin explicación no completa la actividad.

Completa el informe con una sección de equipos activos, servicios únicos y los dos últimos eventos. Ejecuta y explica primero esta parte; después intégrala en `salidas/informe-completo.txt`:

```bash
{
    echo 'Equipos activos'
    grep ';activo;' datos/servicios.txt | cut -d';' -f1
    echo
    echo 'Servicios únicos'
    cut -d';' -f2 datos/servicios.txt | LC_ALL=C sort -u
    echo
    echo 'Últimos eventos'
    tail -n 2 datos/eventos.log
} > salidas/secciones-informe.txt
chmod 600 salidas/secciones-informe.txt
```

#### Paso 2. Resuelve los ejercicios obligatorios

Resuelve los enunciados utilizando lo que has practicado. Guarda el comando, el resultado y una explicación breve; puedes consultar los ejemplos y adaptarlos.

1. Integra esos apartados en la secuencia del informe anterior, con encabezados claros. Usa `>` para regenerar el documento completo.
2. Añade una sección con el número de eventos de cada nivel a partir del segundo campo del registro: ERROR 3, INFO 3 y WARN 2.
3. Añade los equipos que tienen errores, sin repetir nombres: web02 y web03.
4. Muestra el total de filas activas y fallidas calculándolo con filtros. Explica por qué su suma coincide con los seis equipos de estos datos.
5. Guarda una copia del informe, vuelve a generarlo y compáralos con `diff -u`. Si incluyes fecha y hora, esa parte puede cambiar; explica la diferencia.
6. Copia el inventario a `trabajo/servicios-ampliado.txt` y añade `echo 'web04;nginx;fallido;30' >> trabajo/servicios-ampliado.txt`. Repite los filtros sobre la copia: deben dar siete equipos y tres fallidos, con cuatro nginx. El registro de eventos no cambia.
7. Regenera el informe con los archivos originales y comprueba que vuelve a mostrar seis equipos y dos fallidos.
8. Comprueba modo 600 y propietario con `stat`. Entrega las órdenes utilizadas en `evidencias/07-informe.md`, explicando de qué archivo procede cada sección.

**Reto final:** intercambia solo los comandos con otro compañero. Debe poder reproducir el informe en una zona de práctica nueva con los mismos datos, sin depender de rutas personales escritas a mano.

## Entrega y valoración

Entrega una carpeta con `datos`, `salidas` y `evidencias`. Las evidencias deben incluir la explicación individual de todos los comandos propuestos y la resolución de todos los ejercicios numerados. `trabajo` puede conservarse para demostrar pruebas, pero no hace falta entregar archivos ajenos al ejercicio ni el historial completo de tu terminal.

| Apartado | Peso |
|---|---:|
| Terminal, ayuda, rutas y archivos | 20 % |
| Permisos y recuperación | 20 % |
| Redirecciones y explicación de canales | 20 % |
| Filtros y búsquedas | 25 % |
| Informe reproducible y documentación | 15 % |

En cada apartado: 0 si falta o es incorrecto; mitad del peso si funciona parcialmente pero falta una comprobación; peso completo si funciona y se explica. Es una rúbrica de repaso, no una nueva ponderación de resultados de aprendizaje del módulo.

La realización completa incluye todos los ejercicios y la explicación individual de los comandos. La estimación anterior de cinco horas no cubre este conjunto completo; el tiempo de trabajo y los plazos se organizarán dentro de la planificación de UD1.
