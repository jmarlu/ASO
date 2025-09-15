# Estructura CASE

Estructura parecida al 🔀 IF.

```bash
    case VARIABLE in
      OPCION_A)
              ACCIONES;;
      OPCION_B)
              ACCIONES;;
      *)
              ACCIONES;;
    esac

```

Va realizando comprobaciones y cuando una coincida, realiza una serie de acciones programadas y finaliza la condición.

- Cada opción debe ir finalizada de paréntesis “)”.

- Cada acción debajo de cada condición debe ir finalizada de doble punto y coma “;;”

- Con el metacaracter “\*” conseguimos que coincida cualquier cosa, por lo que siempre se cumplirá la condición. **Es equivalente al “else”**.

- Se puede hacer uso de expresiones regulares.

- Se debe usar **“esac”** para finalizar la estructura.

### Ejemplo 1. Ejemplo de un Menú.

```bash title=""


echo "1. Agregar Usuario."
echo "2. Eliminar Usuario."
echo "3. Bloquear Usuario."
echo "4. Salir."

read -p "Elige una opcion: " opcion

case $opcion in
        "1")
                echo "Has elegido la opcion 1"
                echo "Ahora creariamos el usuario";;
        "2")
                echo "Has elegido la opcion 2, vamos a eliminar al usuario";;
        "3")
                echo "Has elegido la opcion 3 ...";;
        "4")
                exit;;
        *)
                echo "El usuario ha insertado cualquier otra cosa."
esac
```

### Ejemplo 2. Múltiples líneas de ejecución por opción

Es importante que quede claro que podemos añadir varios comandos/acciones por cada opción, como se puede ver en el siguiente ejemplo en las opciones 0) y \*).

  <img src="../imagenes/23.png" width="700"/>

### Ejemplo 3. El uso de operadores binarios en el case

También podemos hacer uso de la | para integrar dos opciones posibles, es decir, que tanto si se cumple una u otra se ejecutarán los comandos asociadas a esa comprobación:

Por ejemplo en el siguiente ejemplo, la primera comprobación será verdadera si nombre vale “álvaro” o “pepe”

<img src="../imagenes/24.png"/>

<img src="../imagenes/25.png"/>

### Ejemplo 4. El uso de ;;&

<center>
!!! danger 
        
        "Con 🔀 ;;& 🔀 podemos ejecutar múltiples condiciones"
</center>

- Con “;;” le decimos al script que si se cumple esa condición termine la estructura y salga del “case” (una línea después del esac).

- Usando **“;;&”** estamos indicando que en caso de ser cierta esa comprobación, ejecute las instrucciones asociadas, pero que siga comprobando el resto de opciones y si hay alguna cierta ejecute también las acciones asociadas a ella.

En el siguiente ejemplo la primera cláusula tiene un “;;&”, por lo que por ejemplo si el usuario selecciona “Viernes” se mostrará por pantalla “A estudiar” y posteriormente se mostrará también “A descansar”, puesto que seguirá comprobando el resto de condiciones de la estructura case.

<img src="../imagenes/22.png">
