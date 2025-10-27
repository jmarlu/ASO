# Operaciones Matemáticas

## Operaciones básicas

| Símbolo | Significado         |
| :-----: | :------------------ |
|   `*`   | Multiplicación      |
|   `/`   | División            |
|   `-`   | Resta               |
|   `+`   | Suma                |
|   `%`   | Resto (5 % 2 = 1)   |

## Métodos aritméticos en Bash

| Método  | Uso recomendado                                            | ¿Soporta decimales? | Sintaxis básica                               |
| ------- | ---------------------------------------------------------- | ------------------- | --------------------------------------------- |
| `(( ))` | Operaciones entre enteros y lógica habitual de programación | No                  | `resultado=$(( a + b ))`                      |
| `let`   | Incrementos/decrementos sobre variables ya declaradas       | No                  | `let "contador+=1"`                           |
| `expr`  | Compatibilidad POSIX y utilidades con cadenas               | Parcial (`length`)  | `expr 2 \* 3`, `expr length "$cadena"`        |
| `bc`    | Cálculos con decimales o funciones avanzadas                | Sí                  | `resultado=$(echo "scale=2; 5/3" \| bc)`      |

### `(( ))` — Expresiones aritméticas

Acepta la sintaxis habitual de los lenguajes de programación para enteros. Dentro del doble paréntesis no es necesario anteponer `$` a las variables.

```bash
total=$(( aciertos + fallos ))
porcentaje=$(( aciertos * 100 / intentos ))
```

### `let` — Incrementos rápidos

Permite modificar variables existentes de forma compacta, útil para contadores.

```bash
let "mult = cantidad * precio_unitario"
let "mult *= 3"
let mult++
let mult--
```

### `expr` — Herencia POSIX y cadenas

Ofrece aritmética básica y funciones sobre cadenas. Necesita escapar los caracteres especiales (`*`, `(`, `)`, `<`, `>`).

```bash
expr 2 \* 3
expr \( 2 + 2 \) \* 3

expr length "Hola Mundo"     # Devuelve 10
expr substr "Hola Mundo" 6 5 # Devuelve Mundo
```

### `bc` — Calculadora con decimales

`bc` es una calculadora de precisión arbitraria. Lee expresiones desde la entrada estándar, por lo que suele combinarse con `echo` o con un heredoc.

```bash
importe=$(echo "scale=2; $kg * $precio" | bc)
media=$(echo "scale=3; $total / $muestras" | bc -l)
```

La opción `scale` fija los decimales deseados y `-l` habilita funciones matemáticas avanzadas.

!!! note "Recuerda"
    - `expr` requiere escapar los caracteres `*`, `(`, `)` y `<`, `>`: `expr 3 \* \( 2 + 1 \)`.
    - En `echo "..." | bc` usa comillas rectas (`"`) o simples (`'`); evita las comillas tipográficas.
    - Prefiere la sustitución de comandos `$( ... )` al estilo antiguo con comillas invertidas.

## Ejemplos en contexto

### Calcular espacio usado por un directorio

```bash
bytes=$(du -sb /var/log | cut -f1)
gb=$(echo "scale=2; $bytes / 1024 / 1024 / 1024" | bc)
echo "Uso de /var/log: $gb GB"
```

Combinamos `du` con `bc` para convertir bytes a gigabytes con dos decimales.

### Generar identificadores consecutivos

```bash
contador=1000
while read -r nombre
do
    id=$(( contador++ ))
    echo "$id;$nombre"
done < alumnos.txt
```

El doble paréntesis permite incrementar el contador sin convertirlo a cadena. Cada iteración genera un ID único para el alumno.
