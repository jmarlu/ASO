# Comparadores en Bash

Comprender los distintos tipos de comparaciones es clave para construir condiciones fiables en tus scripts. Separamos los comparadores más habituales según el tipo de dato y añadimos ejemplos prácticos.

## Comparadores numéricos

| Comparador | Significado                  | Ejemplo práctico |
| :--------: | :--------------------------- | ---------------- |
| `-eq`      | Igual a                      | `[[ $usuarios -eq 50 ]]` → ¿Hay 50 usuarios dados de alta? |
| `-ne`      | Distinto                      | `[[ $intentos -ne 3 ]]` → ¿No ha agotado los 3 intentos? |
| `-gt`      | Mayor que                    | `[[ $uso_memoria -gt 80 ]]` → ¿La RAM supera el 80 %? |
| `-ge`      | Mayor o igual que           | `[[ $dias_sin_backup -ge 7 ]]` → ¿Han pasado 7 días sin copia? |
| `-lt`      | Menor que                    | `[[ $usuarios_activos -lt 10 ]]` → ¿Quedan menos de 10 usuarios conectados? |
| `-le`      | Menor o igual que           | `[[ $procesos -le 100 ]]` → ¿Hay 100 procesos o menos? |

```bash
if [[ $uso_memoria -gt 80 ]]
then
    echo "Atención: memoria por encima del 80 %"
fi
```

## Comparadores de archivos

| Comparador | Significado                               | Ejemplo práctico |
| :--------: | :---------------------------------------- | ---------------- |
| `-e`       | Existe                                     | `[ -e /etc/passwd ]` |
| `-f`       | Es un fichero regular                      | `[ -f /var/log/syslog ]` |
| `-d`       | Es un directorio                           | `[ -d /var/backups ]` |
| `-r`       | Permiso de lectura                         | `[ -r "$fichero_config" ]` |
| `-w`       | Permiso de escritura                       | `[ -w "$HOME/.bashrc" ]` |
| `-x`       | Permiso de ejecución                       | `[ -x /usr/bin/docker ]` |
| `-O`       | Propietario es el usuario actual           | `[ -O "$report" ]` |
| `-G`       | El grupo coincide con el grupo actual      | `[ -G "$script" ]` |
| `-s`       | El fichero no está vacío                   | `[ -s /tmp/informe.txt ]` |
| `-L`       | Es un enlace simbólico                     | `[ -L /usr/bin/python ]` |

```bash
if [[ -d $backup_dir && -w $backup_dir ]]
then
    echo "Preparado para guardar la copia en $backup_dir"
else
    echo "No se puede escribir en $backup_dir"
fi
```

## Comparadores de cadenas

| Comparador | Significado                       | Ejemplo práctico |
| :--------: | :-------------------------------- | ---------------- |
| `=`        | Igualdad                          | `[[ $usuario = "root" ]]` |
| `!=`       | Distinto                          | `[[ $estado != "OK" ]]` |
| `-n`       | Cadena no vacía                   | `[[ -n $HOSTNAME ]]` |
| `-z`       | Cadena vacía                      | `[[ -z $respuesta ]]` |

```bash
if [[ -z $respuesta ]]
then
    echo "No se recibió respuesta del servicio."
fi
```

## Operadores lógicos

| Operador | Significado | Uso típico |
| :------: | :---------- | ---------- |
| `!`      | Negación    | `[[ ! -d $dir ]]` |
| `&&`     | Y           | `[[ -f $cfg && -r $cfg ]]` |
| `||`     | O           | `[[ $rol = "admin" || $rol = "operador" ]]` |

```bash
if [[ -w $archivo && ( -e $dir1 || -e $dir2 ) ]]
then
    echo "Hay permiso de escritura y al menos una de las rutas existe."
fi
```

## Test clásico `[` frente a `[[ ]]`

El comando `[[ ]]` extiende la funcionalidad de `[` (`test`) y evita algunos problemas de expansión. Aun así, ambos son válidos si se respetan los espacios y las comillas.

```bash
# Formas equivalentes para comprobar si la variable está vacía
[ -z "$respuesta" ]
[[ -z $respuesta ]]
```

!!! tip
    Usa `[[ ... ]]` siempre que puedas: mejora la lectura, admite `&&` y `||` y evita errores cuando la variable está vacía o contiene espacios.
