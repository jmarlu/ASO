# Bucles `for` en Bash

## 1. Descripción

Los bucles `for` permiten repetir acciones sobre cada elemento de una lista. Son útiles para recorrer argumentos, resultados de comandos o secuencias numéricas sin necesidad de usar estructuras más complejas.

## 2. Sintaxis con anotaciones

```bash
for elemento in LISTA
do
    ACCIONES
done
```

- `LISTA` puede ser un conjunto de literales, la expansión de un comando o el contenido de una variable.
- `elemento` toma un valor distinto en cada iteración.
- Las instrucciones del bucle van entre `do` y `done`.

### Variante aritmética

```bash
for (( i = 1; i <= LIMITE; i++ ))
do
    ACCIONES
done
```

Esta forma usa sintaxis similar a C para recorrer rangos numéricos.

## 3. Ejemplos escalados

### Ejemplo básico: recorrer literales

```bash
for equipo in switch router firewall
do
    echo "Revisando $equipo"
done
```

### Ejemplo intermedio: procesar resultados de un comando

```bash
readarray -t servicios < <(systemctl list-units --type=service --state=failed --no-legend --plain | cut -d' ' -f1)

for servicio in "${servicios[@]}"
do
    [[ -n $servicio ]] && echo "Servicio con errores: $servicio"
done
```

### Ejemplo aplicado: tratar ficheros con espacios

```bash
while IFS= read -r fichero
do
    echo "Analizando \"$fichero\""
    du -h "$fichero"
done < <(find /var/log -type f -maxdepth 1)
```

En este caso usamos **process substitution** y cambiamos el separador (`IFS`) dentro del bucle para respetar rutas con espacios.

!!! question "Prueba tú"
    Completa la actividad **Tablero de asteriscos** descrita en `docs/UD1/linux/Actividades.md` y prueba distintas combinaciones de filas y columnas para familiarizarte con la sintaxis `for (( ... ))`.

## 4. Buenas prácticas

- Prefiere `$(comando)` en lugar de las comillas invertidas antiguas.
- Cita `"$elemento"` al trabajar con nombres que puedan incluir espacios.
- Evita `for item in $(cat fichero)`; usa `while read` para preservar líneas completas.
- Usa la variante `for (( ... ))` cuando necesites contadores explícitos o saltos controlados.

## 5. Actividades rápidas

- **Actividad 1:** Recorre los usuarios normales del sistema (`getent passwd`) y muestra su UID y directorio personal.
- **Actividad 2:** Utiliza `for (( ))` para generar una tabla de multiplicar configurable por teclado.
- **Actividad 3:** Crea un script que compruebe la conectividad (`ping -c1`) de una lista de hosts guardados en un array y registre los resultados en `monitor.log`.
