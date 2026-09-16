# Filtros de texto

Usaremos datos de prueba incluidos en el bloque. `servicios.txt` tiene seis líneas, sin cabecera, con campos `equipo;servicio;estado;memoria_MiB`. `eventos.log` tiene ocho líneas con cuatro campos separados por un único espacio: fecha, nivel, equipo y mensaje. Son formatos simplificados; no representan todos los registros de un servidor real.

## Seleccionar líneas con grep

```bash
grep ';fallido;' datos/servicios.txt
grep -n ' ERROR ' datos/eventos.log
grep -E ' (ERROR|WARN) ' datos/eventos.log
grep -F 'web02' datos/eventos.log
```

`-n` muestra número de línea, `-i` ignora diferencias de mayúsculas, `-v` invierte la selección, `-c` cuenta líneas seleccionadas y `-F` busca texto literal. `grep -E` activa expresiones regulares extendidas; preferimos esta forma a `egrep`.

| Expresión regular | Significado |
|---|---|
| `^web` | Empieza por web |
| `activo$` | Termina por activo |
| `[0-9]` | Un dígito ASCII |
| `.` | Cualquier carácter de la línea |
| `a*` | Cero o más letras a |
| `a+` | Una o más letras a, con -E |
| `(ERROR|WARN)` | Una de las dos alternativas, con -E |

Usa el carácter ASCII `^`, no `ˆ`, y comillas rectas. Los espacios también forman parte de la expresión: `^[bB]uenas (tardes|noches)$` reconoce frases completas con un espacio entre palabras.

No confundas regex y patrones de archivos: `*.txt` es útil para Bash/find, pero no expresa «cualquier nombre terminado en .txt» como regex. Una regex con cuatro grupos de uno a tres dígitos no valida por sí sola una dirección IPv4: admitiría valores superiores a 255.

Si no hay coincidencias, `grep` devuelve 1; con coincidencias devuelve 0. Un error de uso o lectura suele devolver 2. No interpretes todos los estados distintos de cero como la misma situación. Referencia: [manual GNU Grep](https://www.gnu.org/software/grep/manual/grep.pdf).

## Expresiones regulares paso a paso

Una expresión regular describe un patrón de texto. `grep` selecciona las **líneas que contienen una coincidencia**, aunque solo coincida una parte. Usaremos `grep -E` en estos ejemplos para disponer de agrupaciones, alternativas y repeticiones sin escapes adicionales. Escribe el patrón entre comillas simples para que Bash no lo interprete.

### Inicio, final y mayúsculas

Crea un archivo de práctica desde la carpeta del laboratorio:

```bash
mkdir -p trabajo
{
    echo 'Cerdo'
    echo 'Ternera'
    echo 'Buey'
    echo 'rata'
    echo 'Rata'
    echo 'buey'
} > trabajo/animales.txt
```

| Comando | Resultado | Explicación |
|---|---|---|
| `grep -E '^[bB]' trabajo/animales.txt` | `Buey`, `buey` | La primera letra es b o B |
| `grep -i '^b' trabajo/animales.txt` | `Buey`, `buey` | La opción `-i` ignora mayúsculas |
| `grep -E 'a$' trabajo/animales.txt` | `Ternera`, `rata`, `Rata` | La última letra es a |
| `grep -E '^rata$' trabajo/animales.txt` | `rata` | Coincide toda la línea, respetando mayúsculas |
| `grep -Ei '^rata$' trabajo/animales.txt` | `rata`, `Rata` | Coincide toda la línea, ignorando mayúsculas |
| `grep -Ev '^[bB]' trabajo/animales.txt` | `Cerdo`, `Ternera`, `rata`, `Rata` | Selecciona las líneas que no empiezan por b o B |

Los resultados separados por comas en las tablas aparecen **uno por línea** en la terminal. `grep -x 'rata'` también exige que coincida la línea completa.

### Alternativas y agrupaciones

```bash
echo 'Buenas tardes' | grep -E '^[bB]uenas (tardes|noches)$'
echo 'buenas noches' | grep -E '^[bB]uenas (tardes|noches)$'
echo 'buenas tardes a todos' | grep -E '^[bB]uenas (tardes|noches)$'
```

Las dos primeras órdenes muestran la frase; la tercera no muestra nada y devuelve 1. `[bB]` permite dos letras, los paréntesis agrupan y `|` significa «una alternativa u otra». El espacio antes de los paréntesis es obligatorio en este patrón.

`^(web|ldap)` selecciona líneas que empiezan por web o ldap. En cambio, `^web|ldap` selecciona líneas que empiezan por web **o contienen ldap en cualquier posición**: los paréntesis cambian el alcance de la alternativa.

### Repeticiones: `*`, `+`, `?` y llaves

| Patrón con `grep -E` | Acepta, por ejemplo | Rechaza, por ejemplo |
|---|---|---|
| `^ab*c$` | `ac`, `abc`, `abbbc` | `abb` |
| `^ab+c$` | `abc`, `abbbc` | `ac` |
| `^ab?c$` | `ac`, `abc` | `abbc` |
| `^web[0-9]{2}$` | `web01`, `web23` | `web1`, `web001` |
| `^web[0-9]{1,3}$` | `web1`, `web01`, `web123` | `web`, `web1234` |
| `^web[0-9]{2,}$` | `web01`, `web1234` | `web1` |
| `^(ha){2}$` | `haha` | `ha`, `hahaha` |

El repetidor afecta al elemento anterior: un carácter, una clase como `[0-9]` o un grupo entre paréntesis. `*` permite cero repeticiones; por eso `^ab*c$` acepta `ac`. Sin anclas, `a*` puede coincidir con una cadena vacía y seleccionar líneas que no contienen ninguna a.

```bash
echo 'ac' | grep -E '^ab*c$'
echo 'ac' | grep -E '^ab+c$'
echo 'web07' | grep -E '^web[0-9]{2}$'
echo 'haha' | grep -E '^(ha){2}$'
```

Se muestran `ac`, `web07` y `haha`; la segunda orden no tiene coincidencia.

### Punto literal y clases de caracteres

```bash
echo 'informe.txt' | grep -E '^informe\.txt$'
echo 'informeXtxt' | grep -E '^informe\.txt$'
echo 'informeXtxt' | grep -E '^informe.txt$'
```

La primera y la tercera órdenes coinciden; la segunda no. El punto sin escapar acepta cualquier carácter de la línea; `\.` exige un punto literal. Para buscar simplemente el texto `.txt`, puedes usar `grep -F '.txt'`.

| Patrón | Qué reconoce |
|---|---|
| `[[:digit:]]` | Un dígito |
| `[[:alpha:]]` | Una letra, según la localización |
| `[[:alnum:]_]` | Una letra, un dígito o un guion bajo |
| `[[:blank:]]+` | Uno o más espacios o tabulaciones |
| `[^;]+` | Uno o más caracteres distintos de punto y coma |
| `^$` | Una línea vacía |
| `^[[:space:]]*$` | Una línea vacía o compuesta solo por espacios en blanco |

En `[^;]`, `^` niega el conjunto porque aparece al principio de los corchetes; fuera de ellos, `^` marca el inicio de línea. Para ejercicios que requieran exclusivamente rangos ASCII puedes ejecutar `LC_ALL=C grep -E 'patrón' archivo`.

### Ejemplos con el inventario y los registros del aula

Ejecuta estas órdenes con los archivos `datos/servicios.txt` y `datos/eventos.log` del laboratorio:

```bash
grep -E '^web[0-9]{2};' datos/servicios.txt
grep -E ';(nginx|slapd);' datos/servicios.txt
grep -E ';activo;' datos/servicios.txt
grep -E ';[0-9]{3}$' datos/servicios.txt
grep -Ec ' (ERROR|WARN) ' datos/eventos.log
grep -E ' ERROR web02 ' datos/eventos.log
```

Resultados esperados, en el mismo orden:

1. Las tres filas de web01, web02 y web03.
2. Las cuatro filas cuyo servicio es nginx o slapd.
3. Las cuatro filas de equipos activos. Los delimitadores evitan confundir `activo` con `inactivo`.
4. Las filas de web01 y files01: su último campo tiene tres dígitos.
5. El número `5`: tres líneas ERROR y dos WARN. `-c` cuenta líneas, no el número de coincidencias dentro de cada línea.
6. Los dos errores de web02: `conexion` y `timeout`.

Para mostrar solo los fragmentos coincidentes utiliza `-o`:

```bash
grep -Eo 'web[0-9]{2}' datos/eventos.log
```

Aparecen `web01`, `web02`, `web03` y `web02`, uno por línea. Un mismo equipo puede aparecer varias veces.

### Dirección IPv4: reconocer la forma no basta

```bash
echo '192.168.1.10' | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
echo '999.168.1.10' | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
```

**Las dos líneas coinciden.** El patrón reconoce cuatro grupos de uno a tres dígitos separados por puntos, pero no comprueba el intervalo de 0 a 255.

Como ampliación, podemos construir un patrón para cada octeto:

```bash
octeto='(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])'
echo '192.168.1.10' | grep -E "^($octeto\.){3}$octeto$"
echo '999.168.1.10' | grep -E "^($octeto\.){3}$octeto$"
```

Ahora solo coincide la primera dirección. Las alternativas cubren 250–255, 200–249, 100–199 y 0–99. Este ejemplo no admite ceros iniciales en octetos de varias cifras. Comprueba la forma y el intervalo de los octetos; no demuestra que la dirección esté asignada ni que un equipo sea accesible. Las comillas dobles permiten expandir la variable `$octeto`.

### Practica y comprueba

Antes de ejecutar cada orden, escribe qué líneas esperas obtener:

1. Busca `rata` y `Rata` sin utilizar `-i`.
2. Selecciona las filas de equipos cuyo nombre empieza por web o ldap.
3. Selecciona solo los servicios nginx que están en estado fallido.
4. Cuenta las líneas del registro que no contienen los niveles ERROR ni WARN.
5. Comprueba con `echo` un nombre `backup7` y otro `backup123`: admite de uno a dos dígitos al final.
6. Prueba las direcciones `0.0.0.0`, `255.255.255.255`, `256.1.1.1` y `01.2.3.4` con el patrón de octetos.

??? tip "Pistas y resultados para autocorregirte"
    1. `grep -E '^[rR]ata$' trabajo/animales.txt`: dos líneas.
    2. `grep -E '^(web|ldap)[0-9]+;' datos/servicios.txt`: cuatro filas.
    3. `grep -E ';nginx;fallido;' datos/servicios.txt`: web02 y web03.
    4. `grep -Evc ' (ERROR|WARN) ' datos/eventos.log`: tres líneas.
    5. `grep -E '^backup[0-9]{1,2}$'`: acepta `backup7`, rechaza `backup123`.
    6. El patrón acepta las dos primeras y rechaza las dos últimas.

## Extraer campos y contar

```bash
cut -d';' -f1,3 datos/servicios.txt
wc -l datos/eventos.log
wc -c datos/eventos.log
wc -m datos/eventos.log
```

`cut -d` fija un delimitador y `-f` selecciona campos. No agrupa automáticamente varios espacios consecutivos como un único separador. Para formatos con espacios variables hará falta otro tratamiento. `wc -l` cuenta saltos de línea, `-c` bytes y `-m` caracteres; con caracteres multibyte esas dos últimas cifras pueden diferir.

## Ordenar y eliminar duplicados

```bash
LC_ALL=C sort -t';' -k4,4nr datos/servicios.txt
cut -d';' -f2 datos/servicios.txt | LC_ALL=C sort | uniq -c
```

`-t` fija el separador; `-k4,4` limita la clave al cuarto campo; `n` ordena numéricamente y `r` de mayor a menor. El primer equipo del inventario ordenado será `files01`, con 200 MiB. `LC_ALL=C` fija una ordenación reproducible para estos datos ASCII, sin cambiar permanentemente la sesión.

`uniq` elimina o cuenta repeticiones **adyacentes**. Para eliminar duplicados dispersos, ordena antes o utiliza `sort -u` cuando el orden original no importe.

## Transformar caracteres

```bash
echo 'linux aso' | tr '[:lower:]' '[:upper:]'
echo 'uno   dos' | tr -s ' '
```

`tr` recibe datos por stdin: también puedes usar `tr 'a' 'A' < archivo`. `-s` comprime repeticiones de los caracteres indicados; `-d` elimina caracteres. Los ejemplos usan ASCII: no presupongas conversiones correctas de todas las letras Unicode con cualquier implementación/localización.

`expand` y `unexpand` trabajan con posiciones de tabulación. Sustituir cada tabulación por un único espacio con `tr` no equivale a alinear columnas con `expand`.

## Un resultado útil

```bash
grep ' ERROR ' datos/eventos.log | cut -d' ' -f3 | LC_ALL=C sort | uniq -c
```

Esperado: dos errores de web02 y uno de web03. El delimitador de un espacio es válido porque el conjunto de datos lo garantiza. No extraigas una IP mediante una posición fija de la salida multilínea de `ip a`: esa salida depende de interfaces y configuración.
