# Gestión de archivos

`ls -l` muestra el tipo en el primer carácter: `-` archivo regular, `d` directorio, `l` enlace simbólico, `b` dispositivo de bloques, `c` dispositivo de caracteres, `p` tubería con nombre y `s` socket. Los directorios relacionan nombres con entradas del sistema de archivos; no son simples documentos de texto.

La extensión forma parte del nombre. Las aplicaciones pueden utilizarla como convención, pero `file` examina el contenido para identificar el formato.

```bash
ls -l datos
file datos/servicios.txt
```

## Nombres y límites

En los sistemas de archivos habituales de Linux se distinguen mayúsculas y minúsculas, aunque existen configuraciones diferentes. En un componente de nombre no se admiten `/` ni el byte nulo. El límite depende del sistema de archivos; con frecuencia son 255 **bytes**, no necesariamente 255 caracteres.

Se permiten espacios y numerosos signos especiales: utiliza comillas. Evita nombres confusos en scripts. Un punto inicial oculta el nombre en el listado normal de `ls`, pero no protege el contenido.

## Operaciones básicas

Ejecuta desde la raíz de la práctica:

```bash
mkdir -p trabajo/documentos
cp -- datos/servicios.txt trabajo/documentos/servicios-copia.txt
mv -- trabajo/documentos/servicios-copia.txt 'trabajo/documentos/inventario aula.txt'
cat -- 'trabajo/documentos/inventario aula.txt'
touch trabajo/documentos/vacio.txt
ls -la trabajo/documentos
```

`touch` crea un archivo vacío si no existe; si existe, actualiza sus marcas temporales sin vaciar el contenido. `cp` copia y `mv` mueve o renombra; ambos pueden reemplazar destinos, por lo que conviene comprobarlos antes. `cp -a` permite copiar un árbol conservando atributos en la medida permitida por la cuenta y el destino.

```bash
mkdir trabajo/solo-vacio
rmdir trabajo/solo-vacio
rm -i -- trabajo/documentos/vacio.txt
```

`rmdir` elimina directorios vacíos. `rm` elimina nombres de archivos y no envía normalmente los datos a una papelera. Aquí se usa `-i` para confirmar un único archivo de prueba; no necesitas borrados recursivos.

## Enlaces

```bash
ln -s -- ../datos/servicios.txt trabajo/enlace-servicios
cat trabajo/enlace-servicios
ls -l trabajo/enlace-servicios
```

El destino relativo de un enlace se interpreta desde la carpeta que contiene el enlace. En este caso, desde `trabajo`, `../datos/servicios.txt` alcanza el original. Eliminar el enlace no elimina el archivo original. Si se mueve o desaparece el destino, el enlace puede quedar roto.
