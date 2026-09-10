# Permisos básicos y propietarios

Cada archivo tiene propietario y grupo identificados por UID y GID. `id` muestra tu UID, grupo principal y grupos suplementarios. Los archivos locales `/etc/passwd` y `/etc/group` son fuentes habituales; también puede haber identidades de red. `getent passwd` consulta las fuentes configuradas.

En el modelo básico sin ACL, se comprueba primero si eres propietario; en caso contrario, la pertenencia al grupo del archivo, incluidos grupos suplementarios; finalmente se usan los permisos de otros. No se suman los tres bloques ni se pasa a otro bloque porque el primero deniegue acceso. ACL, privilegios y opciones de montaje pueden introducir condiciones adicionales.

| Permiso | Archivo regular | Directorio |
|---|---|---|
| `r` | Leer contenido | Listar nombres |
| `w` | Modificar contenido | Con `x`, crear, renombrar o eliminar entradas |
| `x` | Solicitar ejecución | Atravesar la ruta y acceder a entradas conocidas |

Un directorio con `x` pero sin `r` permite acceder a un nombre conocido, aunque no enumerarlo. Para acceder a un archivo se necesita atravesar los directorios de su ruta. El borrado depende del directorio contenedor, sujeto a restricciones como sticky bit; no basta con mirar `w` en el archivo.

## chmod

```bash
cp datos/servicios.txt trabajo/privado.txt
chmod u=rw,go= trabajo/privado.txt
stat -c '%a %U %G %n' trabajo/privado.txt
chmod 640 trabajo/privado.txt
```

La primera modificación deja 600; la segunda añade lectura al grupo. Cada dígito es octal: lectura 4, escritura 2, ejecución 1. Por ejemplo, 750 significa `rwxr-x---`, y **permite ejecución al grupo**, no solo al propietario.

Para un script privado usaríamos 700; un script compartido requiere decidir qué usuarios pueden leerlo y ejecutarlo. Escribir `bash archivo.sh` hace que Bash lea el archivo: no equivale a ejecutarlo directamente con `./archivo.sh` y no requiere por sí mismo el bit `x` del archivo.

## umask

`umask` muestra la máscara actual; no hay un valor universal para todas las sesiones. En una creación ordinaria sin ACL predeterminada, se retiran bits del modo solicitado por el programa: suele ser 666 para archivos y 777 para directorios. No es una resta decimal.

| Máscara | Archivo solicitado con 666 | Directorio solicitado con 777 |
|---|---|---|
| 022 | 644 | 755 |
| 002 | 664 | 775 |
| 077 | 600 | 700 |

```bash
(
    umask 077
    touch trabajo/mascara-nuevo.txt
    mkdir trabajo/mascara-directorio
    stat -c '%a %n' trabajo/mascara-nuevo.txt trabajo/mascara-directorio
)
```

Los paréntesis limitan el cambio de máscara a una subshell. Parte de nombres nuevos: `touch` sobre un archivo existente no vuelve a aplicar la máscara. Las ACL predeterminadas y casos más avanzados se estudian en UD4.

## chown y chgrp

Cambiar propietario requiere normalmente privilegios de root. El propietario puede cambiar el grupo a uno al que pertenezca; no puede cambiar arbitrariamente archivos ajenos. En este repaso basta con consultar `id` y practicar sobre un archivo propio:

```bash
chgrp "$(id -gn)" trabajo/privado.txt
stat -c '%U %G %n' trabajo/privado.txt
```

No uses sudo para demostrar una denegación a tu propia cuenta: alteraría lo que se está comprobando.
