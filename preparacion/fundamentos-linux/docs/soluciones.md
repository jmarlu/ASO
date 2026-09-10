# Soluciones orientativas del repaso

Guía docente para los datos incluidos. Aceptar órdenes equivalentes si se explican y producen los resultados correctos. La práctica se ejecuta sin root.

## Terminal, rutas y permisos

`ls -ld datos` muestra la entrada del directorio; `ls -l datos` muestra su contenido. `cd` suele ser una orden interna y `ls` puede aparecer como alias antes de resolver el ejecutable. `bash ls -l` intenta leer `ls` como un archivo de órdenes Bash, no invocarlo como programa de listado.

Desde `trabajo/archivo`, la ruta relativa del original es `../../datos/servicios.txt`. El enlace de la actividad debe crearse desde la raíz con `ln -s archivo/inventario.txt trabajo/enlace-inventario`.

Con 000, la lectura por el propietario sin privilegios falla; el propietario sigue pudiendo cambiar el modo con chmod. Con 600 vuelve a leer. Para borrar una entrada importan los permisos del directorio; la ausencia de escritura en el archivo no impide por sí misma el borrado. La prueba parte de un directorio propio sin sticky ni ACL especiales.

## Redirecciones

```bash
 date --iso-8601=seconds > salidas/sesion.txt
 id >> salidas/sesion.txt
 ls -ld datos ruta-inexistente > salidas/listado.txt 2> salidas/errores.txt
 ls -ld datos ruta-inexistente > salidas/juntos.txt 2>&1
 ls -ld datos ruta-inexistente 2>&1 > salidas/solo-stdout.txt
 wc -l < datos/servicios.txt
```

En la última orden ls, stderr conserva el destino anterior de stdout; por eso se ve en la terminal. La cuenta de líneas es 6. No penalizar el código de error intencionado, pero exigir que se explique.

## Filtros e informe integrado

Este bloque es una posible solución completa; se puede ejecutar desde la raíz de la práctica:

```bash
{
    printf 'Informe del aula\n'
    date --iso-8601=seconds
    id
    printf '\nTotal de equipos: '
    wc -l < datos/servicios.txt
    printf '\nEquipos fallidos:\n'
    grep ';fallido;' datos/servicios.txt | cut -d';' -f1
    printf '\nInventario por memoria:\n'
    LC_ALL=C sort -t';' -k4,4nr datos/servicios.txt
    printf '\nEquipos por servicio:\n'
    cut -d';' -f2 datos/servicios.txt | LC_ALL=C sort | uniq -c
    printf '\nErrores por equipo:\n'
    grep ' ERROR ' datos/eventos.log | cut -d' ' -f3 | LC_ALL=C sort | uniq -c
} > salidas/informe-aula.txt
chmod 600 salidas/informe-aula.txt
stat -c '%a %U %n' salidas/informe-aula.txt
```

Resultados: fallidos web02 y web03. Orden por memoria: files01, web01, ldap01, backup01, web02, web03. Servicios: cron 1, nginx 3, slapd 1, smbd 1. Errores: web02 2, web03 1. La anchura de espacios de `uniq -c` no afecta a la corrección.

Para guardar las filas completas fallidas: `grep ';fallido;' datos/servicios.txt > salidas/fallidos.txt`. Los delimitadores hacen que se seleccione el valor completo del campo. En UTF-8, una letra acentuada suele ocupar más de un byte, por lo que `wc -c` y `wc -m` pueden diferir.

## Búsquedas

```bash
find trabajo/busquedas -type f \( -name '*.txt' -o -name '*.log' \) -print
find trabajo/busquedas -type f -perm -100 -print
find trabajo/busquedas -type f -size 10c -print
find trabajo/busquedas -type f -mmin +120 -mmin -300 -print
find trabajo/busquedas -type f -name '*.txt' -exec wc -l -- {} \;
```

Resultados respectivos: actual.txt y antiguo.log; ejecutable.sh; diez.bin; antiguo.log; cero líneas en actual.txt. El orden de recorrido de find no se garantiza.

## Criterios de revisión

Comprobar la secuencia guardada, no solo el informe final. Pedir al alumno una modificación pequeña, por ejemplo filtrar WARN en lugar de ERROR. Revisar que no duplica encabezados al regenerar, que cita las rutas con espacios y que restaura los permisos después del fallo intencionado.

La guía no se incluirá en el menú del alumnado al integrar. Estar fuera del menú no la hace privada si se copia dentro de un sitio MkDocs: si se desea reservarla, hay que mantenerla fuera de su directorio docs.
