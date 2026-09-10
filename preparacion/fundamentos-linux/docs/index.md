# Fundamentos de GNU/Linux para ASO

Material adaptado del bloque UD2 de ISO. **Borrador revisado, pendiente de integración en ASO.** Se propone como repaso previo a scripting, con 4–6 horas ajustables mediante diagnóstico inicial.

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

## Preparar las prácticas

Descarga [servicios.txt](datos/servicios.txt) y [eventos.log](datos/eventos.log) en una carpeta de tu VM. Abre la terminal en esa carpeta y ejecuta:

```bash
zona_aso=$(mktemp -d "$HOME/aso-fundamentos.XXXXXX")
mkdir -p "$zona_aso"/{datos,trabajo,salidas,evidencias}
cp -- servicios.txt eventos.log "$zona_aso/datos/"
cd "$zona_aso"
printf 'Directorio de práctica: %s\n' "$PWD"
```

Conserva esa ruta. Si abres otra terminal, vuelve a ella con `cd /ruta/real/de/la/practica`. Los ejemplos de teoría parten de su raíz, salvo que indiquen otro directorio; usa los archivos de `trabajo` para las pruebas y conserva los datos originales.

La sintaxis de `mktemp`, las llaves de `mkdir` y la variable `zona_aso` se proporcionan para preparar el entorno; se explicarán durante scripting. Verifica que `id -u` no devuelve 0: las pruebas de permisos deben realizarse sin root.
