# Control de Flujo

## Estructuras

En esta parte se indicará tan sólo la sintaxis de las estructuras alternativas e iterativas, ya que los conceptos teóricos ya se han abordado en el apartado de Shellscript.

### Alternativa Simple

```pwsh
    if ( condición ){
        ejecutar este código si la condición es verdadera
    }
```

### Alternativa doble

```pwsh
    if ( condición ) {
        ejecutar este código si la condición es verdadera
    } else {
        ejecutar este código si la condición es falsa
    }
```

### Alternativa múltiple

```pwsh
    if ( condición1 ) {
        ejecutar este código si la condición1 es verdadera
    } elseif ( condición2 ) {
        ejecutar este código si la condición2 es verdadera
    } else {
        ejecutar este código si todas las condiciones son falsas
    }
```

### El equivalente a case en GNU/Linux

```pwsh
    switch ($valor){
        opción1 { código a ejecutar si opción1 coincide con $valor }
        opción2 { código a ejecutar si opción2 coincide con $valor }
        opciónN { código a ejecutar si opciónN coincide con $valor }
        default { código a ejecutar si ninguna de las opciones coincide }
    }
```

!!! example

        ```pwsh
                $saludo = Read-Host "Escribe un saludo"
                switch ($saludo){
                    "Buenos días" { Write-Host "Saludaste en Castellano" }
                    "Bon dia" { Write-Host "Saludaste en Catalán" }
                    "Bo dias" { Write-Host "Saludaste en Gallego" }
                    "Egun on" { Write-Host "Saludaste en Euskera" }
                    "Good morning" { Write-Host "Saludaste en Inglés" }
                    "Bonjour" { Write-Host "Saludaste en Francés" }
                    "Buon Giorno" { Write-Host "Saludaste en Italiano" }
                    "Bom día" { Write-Host "Saludaste en Portugués" }
                    "Guten Tag" { Write-Host "Saludaste en Alemán" }
                    {$_ -is [string]} { Write Host "La variable que has pasado es una cadena" }
                    default { "Eso no parece un saludo" }
                }

        ```

!!! note

    - Existe la posibilidad de colocar operadores lógicos como opciones de un `switch`, si estos operadores lógicos devuelven un valor verdadero, se ejecutará esa parte del código, si se evalúa a falso, no realizará esa parte del código.

    - El carácter $\_ hace referencia a la variable $saludo, de ese modo es posible realizar operaciones lógicas con el valor pasado.

- Además de todo esto, `switch` posee una serie de opciones que no están presentes en GNU/Linux, aunque es posible realizarlas de otra manera.

| Operador         | Descripción                                                                         |
| ---------------- | ----------------------------------------------------------------------------------- |
| `-wildcard`      | Sólo aplicable a `[string]`. Indica si cumple un patrón determinado.                |
| `-exact`         | Sólo aplicable a `[string]`. Debe coincidir exactamente con alguno de los patrones. |
| `-casesensitive` | Sólo aplicable a `[string]`. Debe coincidir en mayúsculas y minúsculas.             |
| `-file`          | La entrada es un archivo. Se evaluará cada línea del archivo.                       |
| `-regex`         | Sólo aplicable a `[string]`. Permite usar expresiones regulares en la comparación.  |

!!! example

         `-regex`

        ```pwsh
            $target = 'https://bing.com'
            switch -Regex ($target){
            '^ftp\://.*$' { "$_ is an ftp address"; Break }
            '^\w+@\w+\.com|edu|org$' { "$_ is an email address"; Break }
            '^(http[s]?)\://.*$' { "$_ is a web address that uses $($matches[1])"; Break }
        }
        ```

!!! example

            `-wildcard`

        ```pwsh
             switch -wildcard ( Read-Host "Escribe un número de teléfono" ){
              "8*" { Write-Host "Es un teléfono fijo: $_"; break }
              "9*" { Write-Host "Es un teléfono fijo: $_"; break }
              "6*" { Write-Host "Es un teléfono móvil: $_"; break }
                default { "$_ no parece un teléfono" }
            }
        ```

- El comando break que aparece al final de cada opción indica que si encuentra una coincidencia no siga buscando más y rompa el switch, ahorrándose así el resto de comprobaciones.

### Estructuras iterativas

#### while

A diferencia de lo que ocurría en GNU/Linux, en PowerShell existen diferencias entre las estructuras **while, do while** y **do until**. En este caso, la única de las tres que evaluará la condición al inicio del bloque de código será la primera. El resto comprueba la condición al final del bloque ejecutando como mínimo una vez el código que contiene.

```pwsh
while ( condición ){
    bloque de código a ejecutar mientras condición sea verdadera
}
```

```pwsh
do {
    bloque de código a ejecutar mientras condición sea verdadera
} while ( condición )
```

Existe una variante de esta estructura que se crea sustituyendo el **while por un until**. Esto cambia el sentido de la condición y es este caso el bloque se repite hasta que la condición se cumpla. Esta estructura no es muy utilizada, pero siempre es bueno contar con herramientas extra.

#### for

También la estructura `for` es sensiblemente diferente que en shellscript. Esta estructura en PowerShell tiene más que ver con los lenguajes de programación y se utiliza cuando el programador sabe el número de iteraciones que hay que realizar para solucionar un problema.

```pwsh
for ( inicialización; condición; incremento ){
    bloque de código a ejecutar mientras condición sea verdadera
}
```

- Por ejemplo, la creación de la tabla de multiplicar de un número especificado por el usuario. Para resolver este problema sí se conoce el número de iteraciones necesarias, concretamente diez.

!!! example

    ```pwsh
    $numero = Read-Host "Dame un número"
    Write-Host "Esta es la tabla del $num"
    for ( $i=0; $i -lt 11; $i++){
        Write-Host " $i x $numero = "($i*$numero)
    }

    ```

#### foreach

La estructura `foreach` en PowerShell es el equivalente a for en shellscript. Está pensada para recorrer un conjunto de valores y ejecutar el bloque de código una vez por cada elemento del conjunto.

```pwsh
foreach ( elemento in conjunto ){
 bloque de código a ejecutar por cada elemento del conjunto
}
```

Al igual que ocurre en GNU/Linux, el conjunto puede serlo de cualquier tipo de objetos, incluso los ficheros de una carpeta. En el siguiente ejemplo se buscan los ficheros que en su nombre contengan la cadena de texto que el usuario ha especificado:

!!! example

        ```pwsh
            $ruta = "C:\Users\Administrador\Desktop"
            $busca = Read-Host "Escribe el texto a buscar"
            foreach ($archivo in Get-ChildItem $ruta){
                if ($archivo.Name.IndexOf($busca) -ge 0){
                Write-Host $archivo.Name
                }
            }
        ```

Otro ejemplo con el misma salida.

!!! example

        ``` PowerShell title=""
        Foreach ($elemento in Get-Process) {

        "{0} arrancado el : {1}" -f $elemento.Name, $elemento.StartTime
        }

        ```

        En este segundo forma se utiliza un pipeline.
        ``` PowerShell title=""
        Get-Process | Foreach {
        ’{0} arrancado el : {1}’ -f $_.Name, $_.StartTime
        }

        ```

!!! note

    Las opciones que ofrece PowerShell en cuanto a estructuras de control parece una oferta más completa que la de shellscript, aunque para las tareas que se van a realizar en este módulo, ambos sistemas poseen herramientas suficientes.
