## Corrección rápida para 20 entregas
1. Reúne todas las carpetas entregadas en un mismo directorio (por ejemplo, `entregas/alu01`, `entregas/alu02`, …). Cada carpeta debe contener los tres scripts con sus nombres originales.
2. Lanza el script de autocorrección incluido en el repositorio:  
   ```bash
   ./docs/Examenes/corregir_examen_shell.sh entregas --csv resultados.csv
   ```  
   - Muestra por pantalla una tabla con las notas parciales (E1/E2/E3) y un total sobre 10.  
   - Crea (opcional) un CSV para importar a la hoja de calificaciones.
3. El script genera pruebas mínimas para cada ejercicio (argumentos válidos/erróneos, ficheros de ejemplo, casos límite) y añade observaciones cuando falla algún criterio del enunciado.
4. Revisa las observaciones destacadas en el CSV para hacer una comprobación manual rápida sólo en los casos dudosos.

> El guion usa únicamente herramientas estándar (bash, awk, grep). Si no tienes `rsync`, copiará cada entrega con `cp -R`. Puedes ajustar los ficheros de prueba que genera en la propia cabecera del script si necesitas escenarios distintos.
