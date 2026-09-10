# Terminal, órdenes y ayuda

El terminal permite interactuar con un intérprete de órdenes o shell. En este bloque utilizaremos **Bash**. El terminal es la interfaz; Bash interpreta lo escrito y ejecuta órdenes internas o programas externos.

## Leer una orden

La forma habitual es `comando opciones argumentos`. No se antepone `bash` a cada orden.

```bash
ls -la datos
pwd
id
```

`ls` lista; `-l` pide detalles; `-a` incluye nombres ocultos; `datos` es el directorio consultado. La combinación de opciones cortas depende de cada programa. `--` suele marcar el final de las opciones, útil para archivos cuyos nombres empiezan por guion.

Un prompt como `alumno@servidor:~$` suele mostrar usuario, equipo y directorio. `~` representa el directorio personal. `$` y `#` son convenciones visuales, configurables: consulta `id` para conocer la identidad real. No copies el prompt al ejecutar ejemplos.

## Comillas y patrones de nombres

```bash
printf 'Documento\n' > 'trabajo/informe de aula.txt'
ls -l -- 'trabajo/informe de aula.txt'
printf '%s\n' datos/*
```

Las comillas agrupan un argumento y evitan que el shell interprete sus caracteres especiales. Las simples conservan el texto literalmente; las dobles permiten, entre otras cosas, expandir variables como `"$HOME"`.

| Patrón Bash | Qué representa |
|---|---|
| `*.txt` | Nombres terminados en .txt |
| `web?.log` | Un carácter después de web |
| `[ab]*` | Nombres que empiezan por a o b |
| `[!ab]*` | Nombres cuyo primer carácter no es a ni b |

`!` no es una negación genérica fuera de los corchetes. Por defecto, `*` no incluye nombres que empiezan por punto; si un patrón no coincide, Bash normalmente lo conserva como texto. Estos patrones no son las expresiones regulares de `grep`.

## Consultar ayuda

```bash
ls --help
man ls
help cd
type cd
type ls
```

En `man`: `/palabra` busca, `n` continúa y `q` sale. `man -k palabra` busca descripciones cuando está disponible su índice. `help` documenta órdenes internas de Bash. Si la VM mínima no incluye manuales, el docente puede preparar `man-db` antes de la sesión.

## Controlar la sesión

- Tab completa nombres; las flechas recorren el historial.
- Ctrl+C envía una interrupción al trabajo en primer plano; su efecto depende del programa.
- Ctrl+Z suspende normalmente ese trabajo; `fg` lo reanuda en primer plano.
- Ctrl+D sobre una entrada vacía comunica fin de entrada; en un prompt Bash puede cerrar la sesión.
- `clear` limpia la vista; no borra el historial. `exit` sale del shell: no equivale a terminar necesariamente todos los procesos iniciados.

`orden1 ; orden2` ejecuta la segunda aunque falle la primera. `orden1 && orden2` continúa solo si la primera termina con éxito; `orden1 || orden2` ejecuta la segunda si la primera falla.

```bash
mkdir trabajo/entrada && ls -ld trabajo/entrada
```

Si repites el ejemplo, `mkdir` avisa de que ya existe y `ls` no se ejecuta. Recupera el código de la última orden inmediatamente con `echo $?`: habitualmente 0 indica éxito.
