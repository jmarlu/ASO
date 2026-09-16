# Terminal, órdenes y ayuda

El terminal permite interactuar con un intérprete de órdenes o shell. En este bloque utilizaremos **Bash**. El terminal es la interfaz; Bash interpreta lo escrito y ejecuta órdenes internas o programas externos.

## Terminal y shell no son lo mismo

Un **emulador de terminal** es la ventana que muestra texto, recibe pulsaciones y permite abrir sesiones. La **shell** es el programa que interpreta órdenes dentro de esa ventana. Por ejemplo, GNOME Terminal puede ejecutar Bash, Zsh o Fish; cambiar el aspecto del terminal no cambia necesariamente la shell.

Puedes comprobar ambos elementos con:

```bash
printf 'Terminal: %s\n' "${TERM_PROGRAM:-no identificado}"
printf 'Shell configurada: %s\n' "$SHELL"
printf 'Proceso actual: '
ps -p $$ -o comm=
```

`$SHELL` suele indicar la shell configurada para iniciar sesión, mientras que `ps -p $$ -o comm=` muestra el proceso que interpreta la sesión actual. No siempre tienen que coincidir.

## Emuladores de terminal para GNU/Linux

La disponibilidad exacta depende de la distribución y de sus repositorios. En Ubuntu se pueden instalar varios con `apt`:

| Terminal | Características principales | Instalación en Ubuntu |
|---|---|---|
| **GNOME Terminal** | Integrado en GNOME; perfiles, pestañas, colores y atajos configurables | `sudo apt install gnome-terminal` |
| **Konsole** | Terminal de KDE Plasma; perfiles, pestañas, paneles divididos y marcadores | `sudo apt install konsole` |
| **Xfce Terminal** | Ligero, sencillo y adecuado para escritorios con pocos recursos | `sudo apt install xfce4-terminal` |
| **Tilix** | Organiza varias terminales en paneles horizontales y verticales | `sudo apt install tilix` |
| **Kitty** | Aceleración gráfica, pestañas, divisiones y configuración mediante archivo | `sudo apt install kitty` |
| **Alacritty** | Rápido y de interfaz mínima; su configuración se realiza principalmente mediante archivo | `sudo apt install alacritty` |

Para el curso basta con el terminal incluido en el escritorio. Instalar otro resulta útil para comparar perfiles, pestañas o paneles, pero las órdenes de Bash funcionan igual. En un Ubuntu Server sin entorno gráfico se trabaja normalmente desde la consola de texto o mediante SSH.

### Multiplexores de terminal

`tmux` y GNU Screen no son emuladores gráficos. Permiten mantener sesiones, crear ventanas y paneles dentro de un terminal, y recuperar el trabajo después de una desconexión. Son especialmente útiles al administrar servidores remotos.

```bash
sudo apt install tmux
tmux
```

Dentro de tmux, el prefijo habitual es Ctrl+B. Después, `%` divide verticalmente, `"` divide horizontalmente, `c` crea una ventana y `d` separa la sesión. `tmux attach` vuelve a conectarla.

## Shells habituales

| Shell | Características | Uso habitual |
|---|---|---|
| **Bash** | Muy extendida en GNU/Linux; historial, autocompletado, arrays y lenguaje de scripting completo | Shell principal de esta unidad y scripts de administración |
| **Dash** | Pequeña y rápida; implementa una shell POSIX con menos extensiones que Bash | En Ubuntu suele interpretar `/bin/sh` y scripts del sistema |
| **Zsh** | Autocompletado y expansión avanzados; admite temas y complementos | Uso interactivo y personalización del entorno |
| **Fish** | Sugerencias y resaltado interactivo desde su instalación; sintaxis sencilla, pero no compatible con POSIX | Uso interactivo; sus scripts no deben confundirse con los de Bash |
| **Ksh** | Shell de la familia Korn; influyó en varias funciones de Bash | Entornos Unix y scripts existentes |

`sh` designa una interfaz y un lenguaje tradicional de shell. En Ubuntu, `/bin/sh` suele ser un enlace a Dash. Un script que comienza con `#!/usr/bin/env bash` solicita Bash; uno con `#!/bin/sh` debe evitar extensiones exclusivas de Bash.

```bash
readlink -f /bin/sh
command -v bash dash zsh fish ksh
cat /etc/shells
```

`command -v` solo muestra las shells instaladas y accesibles. Para probar otra sin cambiar la configuración permanente:

```bash
sudo apt install zsh fish
zsh
exit
fish
exit
```

`chsh -s /ruta/de/la/shell` cambia la shell de inicio de sesión del usuario y normalmente se aplica al volver a entrar. Antes de hacerlo, comprueba que la ruta aparece en `/etc/shells`. En el aula no es necesario cambiarla: los ejercicios y scripts se evaluarán con Bash.

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
