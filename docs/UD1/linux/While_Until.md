# Bucles `while` y `until` en Bash

## 1. Descripción

`while` y `until` repiten un bloque de instrucciones mientras una condición siga cumpliéndose (`while`) o hasta que deje de cumplirse (`until`). Son esenciales para lecturas continuas, menús y procesos que dependen de eventos externos.

## 2. Sintaxis con anotaciones

### Bucle `while`

```bash
while [[ CONDICION ]]
do
    ACCIONES
done
```

- El bloque se ejecuta mientras la condición sea verdadera.
- Para evitar bucles infinitos, asegúrate de modificar variables dentro del cuerpo.

### Bucle `until`

```bash
until [[ CONDICION ]]
do
    ACCIONES
done
```

- El bloque se repite hasta que la condición sea verdadera (es decir, mientras sea falsa).
- Ideal para esperar a que un recurso esté disponible.

## 3. Ejemplos escalados

### Ejemplo básico: pedir un número válido

```bash
numero=0

while (( numero < 1 || numero > 10 ))
do
    read -rp "Elige un número entre 1 y 10: " numero
done

echo "Seleccionaste $numero."
```

### Ejemplo intermedio: comprobar usuarios existentes

```bash
read -rp "Introduce un usuario del sistema: " usuario

while ! getent passwd "$usuario" >/dev/null
do
    read -rp "No existe. Prueba con otro: " usuario
done

echo "$usuario es un usuario válido."
```

### Ejemplo aplicado: esperar a una señal externa (`until`)

```bash
archivo_estado="/tmp/proceso_completado.flag"
contador=0

until [[ -f $archivo_estado || contador -eq 5 ]]
do
    echo "Esperando a que aparezca $archivo_estado..."
    sleep 2
    (( contador++ ))
done

if [[ -f $archivo_estado ]]
then
    echo "Proceso marcado como completado."
else
    echo "Tiempo de espera agotado. Revisa el proceso externo."
fi
```

!!! question "Prueba tú"
    Resuelve la actividad **Control de accesos con `usuarios.log`** del cuaderno de prácticas: necesitarás un `while` con contador de intentos y validaciones de entrada.

## 4. Buenas prácticas

- Controla el número de iteraciones para evitar bucles eternos (`contador` + condición).
- Usa `sleep` en bucles que consulten recursos externos para reducir carga.
- Comprueba el valor de salida (`$?`) inmediatamente después de ejecutar un comando dentro del bucle si lo vas a reutilizar.
- Asigna un valor inicial sensato a las variables antes de entrar en el bucle.

## 5. Actividades rápidas

- **Actividad 1:** Usa `while read` para procesar un listado de direcciones IP y realizar un `ping` breve a cada una.
- **Actividad 2:** Escribe un `until` que intente montar un recurso NFS cada 10 segundos hasta que la orden `mount` funcione.
- **Actividad 3:** Construye un menú interactivo con `while` que ofrezca opciones (mostrar fecha, uso de disco, salir) y reaccione según la selección del usuario.
