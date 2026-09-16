# Fundamentos de GNU/Linux para ASO

Material adaptado del bloque UD2 de ISO. **Borrador revisado, pendiente de integración en ASO.** Se propone como repaso previo a scripting. Incluye ejercicios obligatorios de comandos antes de comenzar scripting.

## Recorrido

1. [Terminal, órdenes y ayuda](IntroTerminal.md).
2. [Directorios y rutas](EstructuraDirectorios.md).
3. [Gestión de archivos](gestionArchivos.md).
4. [Permisos básicos](permisosBasicos.md).
5. [Redirecciones y tuberías](redirecciones.md).
6. [Filtros de texto](filtros.md).
7. [Búsqueda de archivos](busquedaArchivos.md).
8. [Actividades y práctica integrada](Actividades.md).

Trabajamos con Bash y utilidades GNU en Ubuntu, con una cuenta normal y un directorio de práctica nuevo. No hace falta modificar discos, GRUB ni usuarios del sistema. Windows queda fuera de este recorrido; las comparaciones pueden tratarse como ampliación.

Al terminar podrás organizar archivos, interpretar permisos, buscar información y convertir varias órdenes en un informe reproducible. Los bloques de código contienen órdenes ejecutables; las salidas esperadas se presentan aparte.

Las [actividades](Actividades.md) son obligatorias en todos los temas. Debes ejecutar y explicar cada comando propuesto por separado, resolver los ejercicios numerados y entregar las evidencias. El profesorado indicará los plazos; la estimación inicial de 4–6 horas no representa el tiempo necesario para completar el conjunto actual.

## Preparar las prácticas

Descarga [servicios.txt](datos/servicios.txt) en una carpeta de tu VM. Abre la terminal en esa carpeta y ejecuta:

```bash
zona_aso=$(mktemp -d "$HOME/aso-fundamentos.XXXXXX")
mkdir -p "$zona_aso"/{datos,trabajo,salidas,evidencias}
cp -- servicios.txt "$zona_aso/datos/"
cd "$zona_aso"
echo "Directorio de práctica: $PWD"
```

Crea ahora `datos/eventos.log` con los ocho registros que utilizan los ejercicios. Copia y ejecuta el bloque completo, incluida la última línea `EOF`:

```bash
cat > datos/eventos.log <<'EOF'
2026-09-01T08:00 INFO web01 inicio
2026-09-01T08:02 ERROR web02 conexion
2026-09-01T08:03 WARN files01 espacio
2026-09-01T08:04 ERROR web03 permisos
2026-09-01T08:05 INFO ldap01 consulta
2026-09-01T08:06 ERROR web02 timeout
2026-09-01T08:07 INFO backup01 copia
2026-09-01T08:08 WARN files01 espacio
EOF
```

La orden `cat` guarda literalmente las líneas comprendidas entre los marcadores `EOF`. Si el archivo ya existe, sustituye su contenido.

Comprueba el contenido del registro:

```bash
wc -l datos/eventos.log
head -n 1 datos/eventos.log
grep -Ec ' (ERROR|WARN) ' datos/eventos.log
```

Debes obtener ocho líneas, la primera línea `2026-09-01T08:00 INFO web01 inicio` y un recuento de cinco líneas ERROR o WARN. Si los resultados no coinciden, vuelve a ejecutar el bloque de creación completo desde el directorio de práctica.

Conserva esa ruta. Si abres otra terminal, vuelve a ella con `cd /ruta/real/de/la/practica`. Los ejemplos de teoría parten de su raíz, salvo que indiquen otro directorio; usa los archivos de `trabajo` para las pruebas y conserva los datos originales.

La sintaxis de `mktemp`, las llaves de `mkdir` y la variable `zona_aso` se proporcionan para preparar el entorno; se explicarán durante scripting. Verifica que `id -u` no devuelve 0: las pruebas de permisos deben realizarse sin root.
