# Estructuras WHILE y UNTIL

## While

```bash
        while [ CONDICIÓN ]
        do
                ACCIONES
        done
```

- El bucle while se repite mientras la condición sea verdadera.

- Es posible realizar bucles infinitos que están siempre ejecutándose, por ejemplo haciendo uso de la sentencia “true”, la cual siempre hace que la comprobación sea verdadera.

```bash title="Bucle infinito"
while [ true ]
                do
                echo "BUCLE INFINITO"
                done
```

- Importante el espacio entre los corchetes y el uso de “do” y “done” para crear la estructura.

### Ejemplo 1. Repite hasta que el usuario meta un numero entre 1 y 10

```bash
read -p "Elige un numero entre 1 y 10" numero


while [ $num -lt 1 && $num -gt 10 ]
do
        read -p "Elige un numero entre 1 y 10" numero
done
```

### Ejemplo 2. Repite hasta que introduzca un usuario válido en el sistema.

```bash
read -p "Introduce un usuario: " usuario

grep -qw $usuario /etc/passwd

while [ $? -ne 0 ]
do
        read -p "Introduce un usuario: " usuario
        grep -qw $usuario /etc/passwd
done
```

## Until

- Muy parecido a la estructura while.

- Se ejecuta mientras la condición sea falsa.

- Sería equivalente a “Hasta que no sea cierto XXXX sigue realizando las tareas del bucle”.

### Ejemplo. No termina hasta que a tenga el valor de 10

```bash
a=0
until [ $a -eq 10 ]
do
        let "a=$a+1"
        echo $a
done
```

  <img src="../imagenes/26.png" width="300"/>
