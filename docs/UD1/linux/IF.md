# Condicionales `if` en Bash

## 1. Descripción

Las sentencias `if` permiten ejecutar bloques de código solo cuando se cumple una condición. Son la base para tomar decisiones en scripts y automatizar respuestas diferentes según la entrada o el contexto del sistema.

## 2. Sintaxis con anotaciones

### Estructura básica

```bash
if [[ CONDICION ]]
then
    ACCIONES
fi
```

- Las comparaciones se hacen dentro de `[[ ... ]]`.
- `then` abre el bloque de instrucciones cuando la condición es verdadera.
- El cierre del bloque siempre se realiza con `fi`.

### Variantes habituales

```bash
# if / else
if [[ CONDICION ]]
then
    ACCIONES_SI
else
    ACCIONES_NO
fi

# if / elif / else
if [[ CONDICION_1 ]]
then
    ACCIONES_1
elif [[ CONDICION_2 ]]
then
    ACCIONES_2
else
    ACCIONES_DEFECTO
fi
```

!!! tip "Recuerda"
    Tabula cada bloque para mejorar la lectura y deja espacios a ambos lados de los operadores (`[[ $edad -ge 18 ]]`).

## 3. Ejemplos escalados

### Ejemplo básico: validación de entrada

```bash
read -rp "¿Eres alumno del centro? (s/n): " respuesta

if [[ $respuesta = "s" ]]
then
    echo "Acceso concedido."
else
    echo "Solo alumnos registrados pueden acceder."
fi
```

### Ejemplo intermedio: comprobar ruta y permisos

```bash
read -rp "Ruta a comprobar: " ruta

if [[ -d $ruta ]]
then
    echo "$ruta es un directorio."
elif [[ -f $ruta && -r $ruta ]]
then
    echo "$ruta es un fichero legible."
else
    echo "La ruta no existe o no puedes leerla."
fi
```

### Ejemplo aplicado: control de recursos

```bash
uso_root=$(df --output=pcent / | tail -n1 | tr -dc '0-9')

if [[ $uso_root -ge 90 ]]
then
    echo "El sistema raíz supera el 90 % de uso."
elif [[ $uso_root -ge 70 ]]
then
    echo "Advertencia: / ocupa el $uso_root %."
else
    echo "Uso de disco en / bajo control ($uso_root %)."
fi
```

!!! question "Prueba tú"
    Revisa la actividad **Script_IF_5.sh** en `docs/UD1/linux/Actividades.md` y desarrolla el script propuesto para practicar la comprobación de rutas con condicionales encadenados.

## 4. Buenas prácticas

- Usa `[[ ... ]]` para evitar problemas con cadenas vacías y soportar `&&` / `||`.
- Cita las variables cuando puedan contener espacios: `[[ -f "$fichero" ]]`.
- Combina condicionales con funciones (`return`/`exit`) para evitar anidar en exceso.
- Explica con comentarios breves las condiciones complejas.

## 5. Actividades rápidas

- **Actividad 1:** Comprueba si un usuario existe (`getent passwd`) y, en caso afirmativo, muestra su directorio personal.
- **Actividad 2:** Pide la hora actual (`date +%H`) y recomienda “Descanso” si está entre 11 y 12, “Comida” si es 14, o “Clase” en cualquier otro caso.
- **Actividad 3:** Solicita una URL y utiliza `curl -Is` para determinar si el servicio responde con código 200. Imprime mensajes diferenciados según el código HTTP recibido.
