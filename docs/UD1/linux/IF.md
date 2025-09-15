# Estructura IF.

Una estructura de programación IF sirve para generar condiciones:

- Si se cumple cierta condición realizaremos una acción, si no, realizaremos otra:

!!! info "Estructura IF simple"  
	```bash
		if [ CONDICIÓN ]
		then
			ACCIONES
		fi 
	```

Cosas que se deben tener en cuenta:

- Hay que dejar un espacio en blanco entre los corchetes.
- Podemos hacer condiciones usando variables, haciendo uso del $, puesto que queremos comparar su contenido.
- Es recomendable tabular (indentar) las acciones para que quede más limpio el código.
- Siempre debe terminar la estructura con “fi”

Podemos crear condiciones con alternativas, donde si no se cumple una condición se realiza otra lista de acciones:

!!! info "Estructura IF ELSE"
	```bash
		if [ condición ]
		then
			ACCIONES
		else
			ACCIONES
			fi
	```

Se pueden anidar muchas condiciones diferentes con el elemento “elif”:

!!! info "Estructura IF ELSE"

	``` bash
	if [ condición ]
	then
		ACCIONES
	elif [ condición ]
	then
		ACCIONES
	elif [ condición ]
	else
		ACCIONES
	fi
	```


## Ejemplos.


### Ejemplo 1.

```bash
read -p  "Cual es tu nombre? " nombre

if [ $nombre = "Salva" ]
then
        echo "Bienvenido Salva"
fi
```

### Ejemplo 2.

```bash
read -p  "Cual es tu nombre? " nombre

if [ $nombre = "Salva" ]
then
        echo "Bienvenido Salva"
        touch fichero.txt
else
        echo "No eres Bienvenido"
        echo "AutoDestruccion"
        rm -f fichero.txt
fi
```

### Ejemplo 3.

```bash
read -p  "Cual es tu nombre? " nombre

if [ $nombre = "Salva" ]
then
        echo "Bienvenido Salva"
        touch fichero.txt
elif [ $nombre = "Pepe" ]
then
        echo "Que tal Pepe?"
else
        echo "No eres Bienvenido"
        echo "AutoDestruccion"
        rm -f fichero.txt
fi
```

### Ejemplo 4.

```bash
read -p "Cual es tu edad? " edad

if [ $edad -ge 33 ]
then
        echo "Tienes la edad de Cristo o mas"
else
        echo "Tienes menos que la edad de Cristo"
fi
```

### Ejemplo 5.

```bash
read -p "Inserta un nombre de archivo: " fic

if [ -f $fic ]
then
        echo "$fic es un fichero"
else
        echo "$fic no es un fichero"
fi
```

### Ejemplo 6.

```bash
read -p "Inserta un directorio: " dir

if [ -e $dir ]
then
        echo "$dir existe, pero no se si es un directorio."
else
        echo "$dir no existe."
fi
```

### Ejemplo 7.

```bash
read -p  "Indica un ficher o directorio: " recurso

if [ -f $recurso ]
then
        echo "$recurso es un fichero"
elif [ -d $recurso ]
then
        echo "$recurso es un directorio"
elif [ -e $recurso ]
then
        echo "$recurso existe pero no es ni un directorio ni un fichero"
else
        echo "El $recurso ni si quiera existe"
fi
```

### Ejemplo 8. Operador [[]]

Con el comando test:

```bash title=""

if [ -w $arch1 -a \( -e $dir1 -o -e $dir2 \) ]
then
...
```

Con el comando [[]]:

```bash title=""

if [[-w $arch1 && ( -e $dir1 || -e $dir2 )]]
then
...
```

## Vídeos de Ejemplo.

1. [Ejemplos de la Estructura IF.](https://youtu.be/dD9zn6mH0MY)

	