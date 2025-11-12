---
search:
  exclude: true
---
# Examen de Shell Scripting (UD1)

> Duración máxima: 120 minutos. Se permite usar la ayuda local (`man`, `help`, `info`) pero no Internet. Se valoran scripts claros, con validaciones mínimas y mensajes comprensibles.
>
> La prueba se califica sobre **10 puntos** repartidos en 3 ejercicios. Cada apartado incluye los criterios de evaluación y ejemplos para orientar al alumnado.

## Ejercicio 1 (1 punto) · Doble de un número
Crea `doble.sh` que reciba **un único argumento numérico** (entero o decimal) y muestre su doble.
- Verifica que se haya pasado justo un argumento y que cumpla un formato numérico básico (usa una expresión regular sencilla o `bc`).
- Calcula `resultado = numero * 2` con `bc` y muestra `El doble de 3.5 es 7.0`.
- Si el argumento es incorrecto, explica el uso correcto y devuelve código de salida distinto de 0.

**Criterios (1 pt)**
- 0.5 pt: validación de argumento (cantidad y tipo).
- 0.5 pt: cálculo correcto con `bc` y mensaje claro.

**Ejemplo**
```
$ ./doble.sh 4
El doble de 4 es 8
```

## Ejercicio 2 (4 puntos) · Inventario de grupos y usuarios
Crea `inventario_grupos.sh` que reciba un fichero con nombres de grupos (uno por línea).
- Valida que el fichero existe y descarta líneas vacías o que comiencen por `#`.
- Para cada grupo usa `getent group` para obtener su GID y la lista de miembros. Si el grupo no existe, muestra un aviso en `stderr`.
- Imprime una tabla con columnas: Grupo, GID, Total de miembros y la lista separada por comas (puedes usar `tr ':' ' '`, `cut` o manipulación con variables).
- El script debe finalizar con código 0 sólo si todos los grupos del fichero existen; en caso contrario devuelve 1.

**Criterios (4 pts)**
- 1.5 pts: validación de argumentos y lectura del fichero (ignorando líneas vacías/comentadas).
- 2 pts: consulta de `getent`, formateo de tablas y recuento de miembros usando herramientas básicas (`cut`, `tr`, shell puro).
- 0.5 pt: manejo de errores (grupos inexistentes) y códigos de salida coherentes.

**Ejemplo**
```
$ cat grupos.txt
# grupos a comprobar
sudo
docker
$ ./inventario_grupos.sh grupos.txt
Grupo   GID   Total   Miembros
sudo    27    2       admin,alumno
docker  999   1       alumno
```

## Ejercicio 3 (5 puntos) · Alertas de capacidad
Crea `alertas_equipos.sh` que lea un fichero `equipos.txt` con líneas `IP nombre disco ram`.
1. Recibe un umbral mínimo (GB) como argumento y valida que sea entero positivo.
2. Comprueba que `equipos.txt` exista; ignora líneas vacías o comenzadas por `#`.
3. Usa `while read -r ip nombre disco ram` para detectar equipos con `disco < umbral` y muestra `ALERTA: srv01 (10.0.0.5) tiene 20GB libres (< 40GB)`.
4. Al final imprime un resumen del número de alertas encontradas.

**Criterios (5 pts)**
- 1.5 pts: validación de argumento y lectura robusta del fichero.
- 3 pts: lógica de comparación y mensajes claros para cada alerta (gestiona líneas vacías/comentadas y valores no numéricos).
- 0.5 pt: resumen final con el total de incidencias.

**Ejemplo**
```
$ ./alertas_equipos.sh 40
ALERTA: srv01 (10.0.0.5) tiene 20GB libres (< 40GB)
Resumen: 1 equipos bajo el umbral
```

> 📌 Entrega: incluye los scripts con permisos de ejecución y un README breve con instrucciones para probar cada ejercicio.

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
