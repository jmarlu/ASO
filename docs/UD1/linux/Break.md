# Exit, Break y Continue

## Exit.

<center>
!!! danger "EXIT"

        El comando **exit** finaliza el script.

</center>

## Break

<center>
!!! danger "BREAK"

        El comando "break" nos saca de un bucle.

</center>

- Nos permite dar por finalizado un bucle (while, until o for).

- En caso de tener un bucle anidado, podemos usar break X para romper y salir de X bucles.

- No hay que confundirlo con exit, el comando exit termina el programa, mientras que break finaliza el bucle en el que está pero continua el programa.

### Ejemplo Break.

```bash
#En el siguiente ejemplo hay un bucle que va desde 0 a 100 incrementando de 1 en 1.
#No obstante, cuando llega al número indicado por el usuario se sale del bucle for y continúa.
read -p "Escribe un numero del 1 al 100: " num

for x in `seq 1 $num`
do
        echo $x
        if [ $x -eq $num ]
        then
                echo "Ya he llegado al numero $num"
                break
        fi
done
echo
echo "El programa no ha terminado."
echo "Simplemente se ha salido del bucle mediante el break."
```

  <img src="../imagenes/29.png" width="400"/>

## Continue

<center>
!!! danger "CONTINUE"
        El comando "continue" manda el programa directamente a la siguiente iteración.
</center>

### Ejemplo Continue

```bash
#En este ejemplo se recorre del 1 al 10 y no se muestra nada para el valor de 5.
for x in `seq 1 10`
do
        if [ $x -eq 5 ]
        then
                continue
        fi

        echo "Vamos a mostrar todos los numeros menos el 5: $x"
done
```

![alt text](../imagenes/30.png)
