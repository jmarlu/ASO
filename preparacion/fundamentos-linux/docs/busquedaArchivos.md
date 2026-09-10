# Buscar archivos con find

`grep` selecciona contenido; `find` recorre directorios y selecciona entradas por nombre y atributos. Trabaja sobre la zona de práctica para que los resultados sean pequeños y no dependan de todo el sistema.

```bash
find datos -maxdepth 1 -type f -name '*.txt' -print
find trabajo -type f -iname '*informe*' -print
find trabajo \( -name '*.txt' -o -name '*.log' \) -type f -print
```

Las comillas evitan que Bash expanda el patrón antes de pasarlo a find. `-maxdepth 1` incluye el punto inicial y sus hijos directos. Los paréntesis agrupan alternativas; `-a` (AND implícito) tiene prioridad sobre `-o` (OR).

## Permisos y propiedad

| Prueba | Significado |
|---|---|
| `-perm 640` | Bits de modo exactamente 640 |
| `-perm -100` | Bit de ejecución del propietario presente; los demás no importan |
| `-perm -110` | Ejecución para propietario y grupo presentes |
| `-perm /111` | Al menos uno de los bits de ejecución presente |
| `-user nombre` | Propietario indicado |

Quitar el guion de `-perm -110` no significa buscar solo ejecución del propietario: cambia de coincidencia de bits a modo exacto. `-readable` y `-writable` consultan accesibilidad para quien ejecuta la búsqueda; no son equivalentes a examinar un único bit.

## Tiempo y tamaño

`-mtime` mide tiempo desde la modificación del contenido, `-atime` desde el acceso y `-ctime` desde el cambio de estado/metadatos. **ctime no es la fecha de creación**. En pruebas por días se cuentan periodos de 24 horas completos; para este repaso usaremos minutos para evitar límites ambiguos.

```bash
find trabajo -type f -mmin +120 -mmin -300 -print
find trabajo -type f -size 102400c -print
```

El primer filtro selecciona, con el redondeo de find, edades de 121 a 299 minutos completos. El segundo exige exactamente 102400 bytes. Las unidades son un sufijo: `c` bytes, `k` unidades de 1024 bytes, `M` de 1048576. Con unidades mayores que el byte, el tamaño se redondea hacia arriba: `-size 100k` no significa exactamente 102400 bytes. Referencia: [manual GNU Findutils](https://www.gnu.org/software/findutils/manual/find.pdf).

La condición original `-mtime -2 -mtime +5` no puede cumplirse: combina menos de dos días con más de cinco. Es preferible expresar primero el intervalo en lenguaje natural y después comprobar sus extremos.

## Ejecutar una orden sobre resultados

```bash
find datos -type f -name '*.txt' -exec wc -l -- {} \;
```

`{}` representa cada ruta encontrada y `\;` cierra la acción: aquí se ejecuta una orden por archivo. La variante `-exec ... {} +` agrupa varias rutas en una invocación cuando el programa admite esa forma.

En este bloque usaremos acciones de consulta. Antes de aplicar cambios masivos hay que revisar la misma selección con `-print`; no se propone ejecutar `chown` ni borrar desde la raíz del sistema.
