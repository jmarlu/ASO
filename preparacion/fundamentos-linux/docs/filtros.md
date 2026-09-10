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
printf 'linux aso\n' | tr '[:lower:]' '[:upper:]'
printf 'uno   dos\n' | tr -s ' '
```

`tr` recibe datos por stdin: también puedes usar `tr 'a' 'A' < archivo`. `-s` comprime repeticiones de los caracteres indicados; `-d` elimina caracteres. Los ejemplos usan ASCII: no presupongas conversiones correctas de todas las letras Unicode con cualquier implementación/localización.

`expand` y `unexpand` trabajan con posiciones de tabulación. Sustituir cada tabulación por un único espacio con `tr` no equivale a alinear columnas con `expand`.

## Un resultado útil

```bash
grep ' ERROR ' datos/eventos.log | cut -d' ' -f3 | LC_ALL=C sort | uniq -c
```

Esperado: dos errores de web02 y uno de web03. El delimitador de un espacio es válido porque el conjunto de datos lo garantiza. No extraigas una IP mediante una posición fija de la salida multilínea de `ip a`: esa salida depende de interfaces y configuración.
