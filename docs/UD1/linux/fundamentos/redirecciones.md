# Redirecciones y tuberías

Cada proceso dispone normalmente de entrada estándar (stdin, descriptor 0), salida estándar (stdout, 1) y error estándar (stderr, 2). En una terminal interactiva suelen estar asociados al terminal; al automatizar pueden conectarse a archivos o a otros procesos.

| Operador | Efecto |
|---|---|
| `> archivo` | Envía stdout al archivo; lo crea o trunca |
| `>> archivo` | Añade stdout al final |
| `2> archivo` | Envía stderr al archivo; lo crea o trunca |
| `2>> archivo` | Añade stderr al final |
| `< archivo` | Lee stdin desde el archivo |
| `2>&1` | Hace que stderr use el destino actual de stdout |
| `|` | Conecta stdout de una orden con stdin de la siguiente |

## Guardar resultados

```bash
printf 'Primera línea\n' > trabajo/redireccion.txt
printf 'Segunda línea\n' >> trabajo/redireccion.txt
wc -l < trabajo/redireccion.txt
```

El resultado es 2. La redirección la prepara Bash antes de ejecutar el programa. No uses el mismo archivo como entrada y salida de una transformación, por ejemplo `sort archivo > archivo`: podrías vaciarlo antes de leerlo.

## El orden importa

Las redirecciones se procesan **de izquierda a derecha**. En `> todo.log 2>&1`, stdout pasa al archivo y después stderr adopta ese destino. En `2>&1 > solo-salida.log`, stderr adopta primero el destino anterior de stdout y no lo sigue cuando stdout cambia después. Véase el [manual de Bash](https://www.gnu.org/s/bash/manual/html_node/Redirections.html).

```bash
ls -ld datos ruta-que-no-existe > salidas/todo.log 2>&1
ls -ld datos ruta-que-no-existe 2>&1 > salidas/solo-salida.log
```

La primera orden guarda tanto la información de `datos` como el error. La segunda guarda solo la salida normal; el error sigue viéndose en la terminal. Ambas órdenes devuelven un estado de error por la ruta inexistente. Es un fallo intencionado de la práctica.

## Tuberías

```bash
cut -d';' -f2 datos/servicios.txt | LC_ALL=C sort | uniq -c
```

La primera orden extrae nombres de servicios; la segunda agrupa iguales al ordenar y la tercera cuenta repeticiones consecutivas. `|` no incluye stderr automáticamente.

Por defecto, Bash devuelve como estado de una tubería el de la última orden. En scripting aprenderemos a tratar los errores del resto de componentes con `pipefail`. Que haya una salida no garantiza que todas las órdenes anteriores hayan funcionado.

Para guardar varios resultados juntos podemos agrupar órdenes:

```bash
{
    printf 'Inventario del aula\n'
    date --iso-8601=seconds
    printf 'Número de equipos: '
    wc -l < datos/servicios.txt
} > salidas/resumen.txt
```

Las llaves agrupan las órdenes y la redirección final recoge su salida. Esta secuencia prepara la futura creación de un script.
