# Examen mock: Fundamentos de GNU/Linux (ASO)

**Fecha:** 27 de octubre de 2026

Entorno: Bash en Ubuntu, usuario sin privilegios (sin `sudo`). Todas las preguntas parten del directorio de práctica (`datos/`, `trabajo/`, `salidas/`) con `eventos.log` tal como se crea en la preparación.

Para la Parte E, crea antes este archivo:

```bash
cat > datos/cuentas.txt <<'EOF'
ES9121000418450200051332
ES91 2100 0418 4502 0005 1332
ES9121000418450200051
es9121000418450200051332
ES91 2100 0418 4502 0005 13320
FR7630006000011234567890189
EOF
```

Para la Parte F, crea antes este archivo:

```bash
cat > datos/errores.log <<'EOF'
2026-09-01T09:00 INFO web01 E000 arranque ip=192.168.1.10
2026-09-01T09:05 ERROR web02 E404 /index.html ip=10.0.0.5
2026-09-01T09:07 ERROR web02 E500 /api/login ip=10.0.0.5
2026-09-01T09:10 WARN files01 E201 espacio=91% ip=192.168.1.20
2026-09-01T09:12 ERROR ldap01 E389 bind-fallido ip=172.16.0.3
2026-09-01T09:15 ERROR web03 E403 /admin ip=999.1.1.1
2026-09-01T09:20 INFO backup01 E000 copia-ok ip=192.168.1.30
2026-09-01T09:22 ERROR web01 E404 /favicon.ico ip=203.0.113.77
2026-09-01T09:30 WARN web02 E503 timeout ip=10.0.0.5
2026-09-01T09:31 ERROR files01 E13 disco-lleno ip=192.168.1.20
2026-09-01T09:40 FATAL db01 E900 caida ip=10.0.0.9
2026-09-01T09:45 ERROR web03 e404 /Index.html ip=256.10.0.1
EOF
wc -l datos/errores.log
```

---

## Parte A. Test

**A1.** ¿Qué es `~` en Bash?

- a) La raíz del sistema de archivos
- b) Una expansión de Bash al directorio personal
- c) El directorio padre
- d) El directorio `/root`

**A2.** ¿Qué directorio contiene el archivo `/home/alumno/datos/informe.txt`?

- a) `/home/alumno`
- b) `/home/alumno/datos/informe.txt`
- c) `/home/alumno/datos`
- d) `/home`

**A3.** El modo `750` de un archivo equivale a:

- a) `rwxr-x---`, con ejecución solo para el propietario
- b) `rwxr-x---`, con ejecución para propietario y grupo
- c) `rwxr-xr--`
- d) `rwx---r-x`

**A4.** Con `umask 077`, un archivo nuevo creado con `touch` queda con modo:

- a) 700
- b) 644
- c) 600
- d) 077

**A5.** En `find`, la prueba `-perm /111` selecciona entradas con:

- a) Exactamente el modo 111
- b) Los tres bits de ejecución presentes
- c) Al menos uno de los bits de ejecución presente
- d) Solo el bit de ejecución del propietario

**A6.** En la salida de `ls -l`, una línea que empieza por `l` corresponde a:

- a) Un archivo de registro (log)
- b) Un enlace simbólico
- c) Un directorio bloqueado
- d) Un dispositivo de bloques

**A7.** ¿Qué hace `orden1 && orden2`?

- a) Ejecuta `orden2` siempre
- b) Ejecuta `orden2` solo si `orden1` falla
- c) Ejecuta `orden2` solo si `orden1` termina con éxito
- d) Ejecuta ambas en paralelo

**A8.** La orden `ls -ld datos ruta-inexistente 2>&1 > salidas/x.log` guarda en `x.log`:

- a) Salida normal y error
- b) Solo el error
- c) Solo la salida normal; el error sigue viéndose en la terminal
- d) Nada

**A9.** ¿Qué mide `-ctime` en `find`?

- a) La fecha de creación del archivo
- b) El último acceso
- c) El último cambio de contenido
- d) El último cambio de estado o metadatos

**A10.** `grep` devuelve el código 1 cuando:

- a) Hay un error de lectura
- b) No hay ninguna línea coincidente
- c) Hay coincidencias
- d) La expresión regular es inválida

---

## Parte B. Predice la salida

Escribe exactamente qué se mostraría, sin ejecutar nada.

**B1.**

```bash
grep -Ev ' (ERROR|WARN) ' datos/eventos.log | cut -d' ' -f3
```

**B2.**

```bash
grep -Eo 'web[0-9]{2}' datos/eventos.log | LC_ALL=C sort | uniq -c
```

**B3.**

```bash
grep ' WARN ' datos/eventos.log | cut -d' ' -f3 | uniq
```

**B4.**

```bash
echo 'web123' | grep -E '^web[0-9]{1,2}$'
echo $?
```

---

## Parte C. Escribe la orden

Una sola orden o tubería por apartado, salvo que se indique otra cosa.

**C1.** Muestra las líneas de `datos/eventos.log` correspondientes a errores de `web02`, con su número de línea.

**C2.** Guarda en `salidas/errores.log` todas las líneas ERROR del registro y, a continuación, muestra solo cuántas líneas contiene ese archivo (sin mostrar su contenido).

**C3.** Ejecuta `ls -ld datos ruta-inexistente` guardando **tanto la salida normal como el error** en `salidas/ls.log`.

**C4.** Copia `datos/servicios.txt` a `trabajo/secreto.txt`, deja el archivo con lectura y escritura para el propietario, solo lectura para el grupo y ningún permiso para otros, y comprueba el resultado mostrando el modo en octal y el nombre.

**C5.** Lista los archivos regulares de `trabajo` cuyo nombre termine en `.txt` o `.log` y que se hayan modificado en los últimos 60 minutos.

**C6.** Estando en `trabajo/documentos`, crea un enlace simbólico llamado `enlace-servicios` que apunte a `datos/servicios.txt` usando una **ruta relativa**.

---

## Parte D. Encuentra el fallo

Indica qué problema tiene cada caso y cómo corregirlo.

**D1.** `sort trabajo/lista.txt > trabajo/lista.txt`

**D2.** `find trabajo -name *.txt` (puede dar resultados raros si hay archivos `.txt` en el directorio actual).

**D3.** Un compañero dice: «`grep -E '^web|ldap' datos/servicios.txt` selecciona las filas que empiezan por web o por ldap».

**D4.** Un compañero dice: «Con `umask 027`, un directorio nuevo queda 750 y un archivo nuevo 640».

---

## Parte E. Expresiones regulares avanzadas (cuentas bancarias)

Usa `grep -E` y, para rangos como `[A-Z]`, `LC_ALL=C`.

**E1.** Selecciona los IBAN españoles **sin espacios** de `datos/cuentas.txt`: `ES`, dos dígitos de control y 20 dígitos (24 caracteres).

**E2.** Selecciona los IBAN españoles **con espacios cada 4 caracteres** (`ES91 2100 0418 4502 0005 1332`).

**E3.** Selecciona los IBAN españoles **con o sin espacios**. ¿Qué defecto tiene tu solución con los espacios mezclados?

**E4.** Selecciona IBAN de **cualquier país**: 2 letras, 2 dígitos y de 11 a 30 caracteres alfanuméricos. ¿Qué líneas coinciden y por qué alguna no debería?

**E5.** Número de tarjeta de 16 dígitos en grupos de 4 con **separador coherente** (espacio o guion, el mismo las tres veces). Pruébalo con:

```bash
echo '4539 1488 0343 6467'
echo '4539-1488-0343-6467'
echo '4539 1488-0343 6467'
```

**E6.** Importe en formato español: miles con punto, decimales con coma, signo opcional. Debe aceptar `1.234,56`, `-12,05`, `1234,50`, `1.000.000,00` y rechazar `1.23,45`, `12,5`, `1,234.56`.

**E7.** Fecha ISO (`2026-09-01`) con mes de 01 a 12 y día de 01 a 31. ¿Acepta `2026-02-31`? ¿Por qué?

**E8.** Extrae solo el IBAN español, sin el resto del texto, de:

```bash
echo 'Transferencia a ES9121000418450200051332 realizada'
```

**E9.** Preguntas de reflexión:

1. ¿Por qué ninguna regex puede validar los dígitos de control del IBAN?
2. ¿Cómo corregirías E3 para no aceptar espacios mezclados?
3. ¿Qué diferencia hay entre `^ES|FR` y `^(ES|FR)`?

---

## Parte F. Expresiones regulares con `errores.log`

Usa `grep -E` y comillas simples. Antes de ejecutar cada orden, anota qué líneas esperas obtener.

### Bloque 1. Anclas y alternativas

**F1.** Cuenta las líneas de nivel `ERROR`.

**F2.** Cuenta las líneas cuyo código empieza por `E4` y tiene tres dígitos en total (en mayúscula).

**F3.** Muestra el nombre de los equipos con nivel `ERROR` o `FATAL` cuyo nombre **no** empiece por `web`.

**F4.** Muestra las líneas de nivel `WARN` o `INFO`, con su número de línea.

### Bloque 2. Repeticiones y clases

**F5.** Selecciona las líneas con un código de **uno o dos dígitos** (por ejemplo `E13`).

**F6.** Selecciona los códigos de cliente y servidor (`E4xx` o `E5xx`) y muestra cuántas veces aparece cada uno (`cut`, `sort`, `uniq -c`).

**F7.** Muestra solo las rutas que terminan en `.html` (campo 5), una por línea.

**F8.** Selecciona las líneas cuya hora esté entre `09:00` y `09:15` ambas incluidas. Pista: dos alternativas en los minutos.

**F9.** Selecciona las líneas cuyo porcentaje de espacio sea del 90% al 100%.

### Bloque 3. Mayúsculas, puntos literales y alcance

**F10.** Cuenta las líneas con código `404` ignorando mayúsculas en la `E`, sin usar `-i`.

**F11.** Explica qué diferencia hay entre estas dos órdenes y qué devuelve cada una:

```bash
grep -E 'ip=10.0.0.5' datos/errores.log
grep -E 'ip=10\.0\.0\.5' datos/errores.log
```

**F12.** Compara y explica:

```bash
grep -E 'ERROR|FATAL web03' datos/errores.log
grep -E '(ERROR|FATAL) web03' datos/errores.log
```

### Bloque 4. Direcciones IP

**F13.** Muestra solo las IP (`-o`, sin el prefijo `ip=`), sin repetidas y ordenadas.

**F14.** Selecciona las líneas cuya IP empiece por `192.168.` o por `10.`.

**F15.** Selecciona las líneas de nivel `ERROR` cuya IP empiece por `10.`.

**F16.** Con la variable `octeto` de `filtros.md`, muestra las líneas con una IP **válida** y después las que tienen una IP **no válida**:

```bash
octeto='(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])'
```

### Bloque 5. Reto

**F17.** Escribe una sola expresión que valide una línea completa con esta forma: fecha ISO con hora, nivel (`INFO|WARN|ERROR|FATAL`), equipo (letras minúsculas seguidas de dos dígitos), código `E` + 1 a 3 dígitos y un último campo `ip=` con una IP válida. ¿Cuántas líneas coinciden?

**F18.** ¿Qué líneas no cumplen la validación del ejercicio F17 y por qué motivo cada una?

---
---

# Solucionario

## Parte A

1-b · 2-c · 3-b · 4-c · 5-c · 6-b · 7-c · 8-c · 9-d · 10-b

- **A2:** el directorio contenedor es `/home/alumno/datos`, no `/home/alumno`.
- **A3:** el segundo dígito (5 = `r-x`) da ejecución al grupo.
- **A4:** se retiran bits de 666, así que queda 600.
- **A8:** `2>&1` se procesa antes que `> archivo`, así que stderr adopta el destino anterior de stdout (la terminal).
- **A9:** ctime no es la fecha de creación.

## Parte B

**B1.**

```
web01
ldap01
backup01
```

**B2.**

```
      1 web01
      2 web02
      1 web03
```

El ancho del contador puede variar, pero los valores son 1, 2 y 1.

**B3.**

```
files01
```

Las dos líneas WARN son de `files01` y quedan adyacentes, así que `uniq` las reduce a una.

**B4.** `grep` no muestra nada y después aparece `1` (hay tres dígitos y el patrón admite de uno a dos).

## Parte C

**C1.** `grep -n ' ERROR web02 ' datos/eventos.log` (líneas 2 y 6)

**C2.**

```bash
grep ' ERROR ' datos/eventos.log > salidas/errores.log
wc -l < salidas/errores.log
```

Resultado: `3`.

**C3.** `ls -ld datos ruta-inexistente > salidas/ls.log 2>&1` (el orden importa)

**C4.**

```bash
cp -- datos/servicios.txt trabajo/secreto.txt
chmod 640 trabajo/secreto.txt
stat -c '%a %n' trabajo/secreto.txt
```

También vale `chmod u=rw,g=r,o=`.

**C5.** `find trabajo -type f \( -name '*.txt' -o -name '*.log' \) -mmin -60 -print`

Los paréntesis escapados son necesarios porque `-a` tiene prioridad sobre `-o`.

**C6.** `ln -s -- ../../datos/servicios.txt enlace-servicios`

La ruta relativa se interpreta desde la carpeta que contiene el enlace (`trabajo/documentos`), por eso hacen falta dos `../`.

## Parte D

**D1.** La redirección se prepara antes de ejecutar `sort`, así que el archivo se vacía antes de leerlo. Solución: `sort trabajo/lista.txt > trabajo/lista-ordenada.txt`, o `sort -o trabajo/lista.txt trabajo/lista.txt`.

**D2.** Sin comillas, Bash puede expandir `*.txt` antes de pasarlo a `find`. Solución: `find trabajo -name '*.txt'`.

**D3.** Falso: `^web|ldap` selecciona líneas que empiezan por `web` **o contienen `ldap` en cualquier posición**. Solución: `grep -E '^(web|ldap)' datos/servicios.txt`.

**D4.** Correcto. Se parte de 777 para directorios (→ 750) y de 666 para archivos (→ 640). No es una resta decimal, sino la retirada de bits.

## Parte E

**E1.** `grep -E '^ES[0-9]{22}$' datos/cuentas.txt` → solo la línea 1. La 3 es corta y la 4 está en minúsculas.

**E2.** `grep -E '^ES[0-9]{2}( [0-9]{4}){5}$' datos/cuentas.txt` → solo la línea 2. La 5 falla por tener cinco dígitos en el último grupo.

**E3.** `grep -E '^ES[0-9]{2}( ?[0-9]{4}){5}$' datos/cuentas.txt` → líneas 1 y 2. Defecto: acepta espacios mezclados (`ES912100 0418...`), porque no obliga a ser coherente.

**E4.** `LC_ALL=C grep -E '^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$' datos/cuentas.txt` → líneas 1, 3 y 6. La línea 3 coincide aunque le falte un dígito: la forma genérica no conoce la longitud de cada país. La regex comprueba la forma, no la validez.

**E5.** `grep -E '^[0-9]{4}([ -])[0-9]{4}\1[0-9]{4}\1[0-9]{4}$'` → coinciden las dos primeras; la tercera no (separadores mezclados). `\1` es una referencia hacia atrás al primer grupo.

**E6.** `grep -E '^-?([0-9]{1,3}(\.[0-9]{3})+|[0-9]+),[0-9]{2}$'`

**E7.** `grep -E '^20[0-9]{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'`. Sí acepta `2026-02-31`: comprueba rangos, no el calendario real.

**E8.** `echo '...' | grep -Eo 'ES[0-9]{22}'`. Sin anclas y con `-o` se muestra solo el fragmento coincidente.

**E9.**

1. Los dígitos de control se calculan con módulo 97 sobre el número entero; una regex solo describe patrones de texto.
2. Con dos alternativas: `^(ES[0-9]{22}|ES[0-9]{2}( [0-9]{4}){5})$`.
3. `^ES|FR` selecciona líneas que empiezan por `ES` **o contienen `FR` en cualquier posición**; `^(ES|FR)` exige que empiecen por una de las dos.

## Parte F

**F1.** `grep -Ec ' ERROR ' datos/errores.log` → `7`

**F2.** `grep -Ec ' E4[0-9]{2} ' datos/errores.log` → `3` (E404, E403, E404). La línea con `e404` no cuenta por la minúscula.

**F3.** `grep -E ' (ERROR|FATAL) ' datos/errores.log | grep -Ev ' web' | cut -d' ' -f3`

```
ldap01
files01
db01
```

**F4.** `grep -nE ' (WARN|INFO) ' datos/errores.log` → líneas 1, 4, 7 y 9.

**F5.** `grep -E ' E[0-9]{1,2} ' datos/errores.log` → solo la línea de `E13` (`files01`). Los espacios alrededor impiden confundir `E13` con parte de `E138`.

**F6.**

```bash
grep -E ' E[45][0-9]{2} ' datos/errores.log | cut -d' ' -f4 | LC_ALL=C sort | uniq -c
```

```
      1 E403
      2 E404
      1 E500
      1 E503
```

**F7.** `grep -E ' /[^ ]+\.html ' datos/errores.log | cut -d' ' -f5`

```
/index.html
/Index.html
```

**F8.** `grep -E 'T09:(0[0-9]|1[0-5]) ' datos/errores.log` → 6 líneas (de 09:00 a 09:15). El espacio final evita aceptar `09:150`.

**F9.** `grep -E 'espacio=(9[0-9]|100)%' datos/errores.log` → la línea de `files01` con `espacio=91%`.

**F10.** `grep -Ec ' [eE]404 ' datos/errores.log` → `3`

**F11.** La primera usa `.` sin escapar, que acepta cualquier carácter: también coincidiría con `10X0Y0Z5`. La segunda exige puntos literales. Con estos datos las dos devuelven las mismas 3 líneas, pero solo la segunda es correcta.

**F12.** La primera busca `ERROR` **o** `FATAL web03` (alternativa sin agrupar): selecciona todas las líneas ERROR más las FATAL de web03 (ninguna). La segunda agrupa y exige que el nivel sea `ERROR` o `FATAL` seguido de ` web03`: devuelve solo las 2 líneas de `ERROR web03`; la primera devuelve las 7 líneas ERROR. Los paréntesis cambian el alcance de la alternativa.

**F13.**

```bash
grep -Eo 'ip=[0-9.]+' datos/errores.log | cut -d= -f2 | LC_ALL=C sort -u
```

```
10.0.0.5
10.0.0.9
172.16.0.3
192.168.1.10
192.168.1.20
192.168.1.30
203.0.113.77
256.10.0.1
999.1.1.1
```

**F14.** `grep -E 'ip=(192\.168|10)\.' datos/errores.log` → 8 líneas.

**F15.** `grep -E ' ERROR .* ip=10\.' datos/errores.log | cut -d' ' -f3` → `web02` y `web02`.

**F16.**

```bash
octeto='(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])'
grep -E "ip=($octeto\.){3}$octeto$" datos/errores.log      # IP válida: 10 líneas
grep -Ev "ip=($octeto\.){3}$octeto$" datos/errores.log     # IP no válida: 2 líneas
```

Las no válidas son `999.1.1.1` (web03, 09:15) y `256.10.0.1` (web03, 09:45).

**F17.**

```bash
octeto='(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])'
grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2} (INFO|WARN|ERROR|FATAL) [a-z]+[0-9]{2} E[0-9]{1,3} [^ ]+ ip=($octeto\.){3}$octeto$" datos/errores.log
```

Coinciden **10** líneas.

**F18.** Fallan 2 líneas:

- Línea 6 (`web03 E403`): IP `999.1.1.1`, primer octeto fuera de rango.
- Línea 12 (`web03 e404`): IP `256.10.0.1` fuera de rango y, además, código con `e` minúscula, que tampoco encajaría con `E[0-9]{1,3}`.

La línea 10 (`E13`) sí cumple, porque el código admite de 1 a 3 dígitos.
