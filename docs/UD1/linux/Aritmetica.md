# Operaciones Matemáticas.

## Operaciones



| Símbolo |  Significado                   |
| :-----: | :----------------------------- |
|   `*`   | Multiplicación                 |
|   `/`   | División                       |
|   `-`   | Resta                          |
|   `+`   | Suma                           |
|   `%`   | Resto. Ej. 5%2 = 1             |



## Comandos Aritméticos.

Existen varias posibilidades para realizar operaciones matemáticas.

### 1. Usando doble paréntesis:

```bash
suma=$(( $x + $y ))
```

### 2. Usando el comando “let”:

```bash
#Ejemplo de Multiplicación:
let "mult = $x * $y"

#Ejemplo de triplicar un valor:
let “mult = $mult * 3”


#Ejemplo de incrementar un valor o decrementar:
let mult++
let mult--
```

### 3. Usar el comando “expr”:

- Este comando es más antiguo y tiene el inconveniente de tener que escaparse (añadir \) delanta de cada carácter especial como \*,<,>,(,), etc.

```bash
#Ejemplo del uso de * y () escapado (\)
expr 2 \* 3
expr \( 2 + 2 \) \* 3
```

- Por contra, expr es útil para comprobar longitud de cadena de caracteres y sustraer subcadenas.

```bash
#Este comando devuelve 10, que es la longitud de la cadena pasada como parámetro.
#Tened en cuenta que se contabiliza cada espacio en blanco como una letra.
expr length “Hola Mundo”

#Desde el carácter n.º 4 (a) devuelve los siguientes 4 caracteres → “a Mu”
expr substr “Hola Mundo” 4 4

#. Desde el carácter número 6, devuelve los siguientes 5 caracteres → “Mundo”
expr substr “Hola Mundo” 6 5
```

### 4. Comando "bc" para decimales.

Para trabajar con decimales debemos usar el comando “bc”:

```bash title=""

	operacion=`echo “7.5 * 12.5” | bc `
```

Las comillas invertidas devuelven el valor de la operación o del comando.

Para sacar todos los posibles decimales usamos la opción “-l”

```bash title=""

    operacion=`echo “7.5 * 12.5” | bc  -l`
```

Si queremos cierto número de decimales usamos la opción scale:

```bash title=""

    operacion=`echo “scale=3;7.5 * 12.5” | bc `
```
