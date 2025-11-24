---
search:
  exclude: true
---
# Examen de Shell Scripting (UD1)

> Duración máxima: 120 minutos. Se permite usar la ayuda local (`man`, `help`, `info`) mis apuntes. Se valoran scripts claros, con validaciones mínimas y mensajes comprensibles.
>
> La prueba se califica sobre **10 puntos** repartidos en 3 ejercicios. Cada apartado incluye los criterios de evaluación y ejemplos para orientarte.

## Ejercicio 1 (1 punto) · Doble de un número
Crea `doble.sh` que reciba **un único argumento numérico** (entero o decimal) y muestre su doble.
- Verifica que se haya pasado justo un argumento y que cumpla un formato numérico básico (usa una expresión regular sencilla o `bc`).
- Calcula `resultado = numero * 2` con `bc` y muestra `El doble de 3.5 es 7.0`.
- Si el argumento es incorrecto, explica el uso correcto y devuelve código de salida distinto de 0.

**Criterios (1 pt)**

  - **0.5 pt**: validación de argumento (cantidad y tipo).
  - **0.5 pt**: cálculo correcto con `bc` y mensaje claro.

**Ejemplo**
```
$ ./doble.sh 4
El doble de 4 es 8
```

## Ejercicio 2 (5 puntos) · Inventario de usuarios
Crea `inventario_usuarios.sh` que reciba un fichero con nombres de usuarios (uno por línea).Que te puedes descargar de la carpeta de Recursos script.
- Valida que se proporcione un único argumento, que el fichero existe/puede leerse y descarta líneas vacías o que comiencen por `#`.
- Para cada usuario usa `getent passwd` para obtener su UID. Si el usuario no existe, muestra un aviso en `stderr` y continúa con el resto.
- Calcula cuántos grupos tiene y muestra la lista separada por espacios o comas empleando utilidades vistas en clase (`groups`, `cut`, `tr`, etc.).
- Imprime una tabla con columnas: `Usuario`, `UID`, `Num.Grupos` y `Grupos`. El script debe finalizar con código 0 solo si todos los usuarios existen; en caso contrario devuelve 1.

**Criterios (5 pts)**

  - **1.5 pts**: validación de argumentos y lectura del fichero (ignorando líneas vacías/comentadas).
  - **3 pts**: consulta de `getent`, cálculo de número de grupos y formateo claro de la tabla usando herramientas básicas (`cut`, `tr`, `wc`, etc.).
  - **0.5 pt**: manejo de errores (usuarios inexistentes) y códigos de salida coherentes.

**Ejemplo**
```
$ cat usuarios.txt
# cuentas a revisar
root
daemon
$ ./inventario_usuarios.sh usuarios.txt
=========================================================================
Usuario              UID        Num.Grupos      Grupos
=========================================================================
root                0         2              root adm
daemon              1         1              daemon
=========================================================================
```

## Ejercicio 3 (4 puntos) · Alertas de capacidad
Crea `alertas_equipos.sh` que lea un fichero `equipos.txt` con líneas `IP;nombre;disco;ram`.Que te puedes descargar de la carpeta de Recursos script.
1. Recibe un umbral mínimo (GB) como argumento y valida que sea entero positivo.
2. Comprueba que `equipos.txt` exista; ignora líneas vacías o comenzadas por `#`.
3. Usa **obligatoriamente** `while read -r ip nombre disco ram` para detectar equipos con `disco < umbral` y muestra `ALERTA: srv01 (10.0.0.5) tiene 20GB libres (< 40GB)`.
4. Al final imprime un resumen del número de alertas encontradas.

**Criterios (4 pts)**

  - **1 pt**: validación de argumento y lectura robusta del fichero.
  - **1.75 pts**: lógica de comparación y mensajes claros para cada alerta (gestiona líneas vacías/comentadas y valores no numéricos).
  - **1.25 pts**: resumen final fiable con el total de incidencias (incluye el caso sin alertas).

**Ejemplo**
```
$ ./alertas_equipos.sh 40
ALERTA: srv01 (10.0.0.5) tiene 20GB libres (< 40GB)
Resumen: 1 equipos bajo el umbral
```

> 📌 Entrega: incluye los scripts con permisos de ejecución y un README breve con instrucciones para probar cada ejercicio.
