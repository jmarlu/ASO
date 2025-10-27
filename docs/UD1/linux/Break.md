# Control del flujo: `exit`, `break` y `continue`

## 1. Descripción

Estas instrucciones permiten salir de scripts o modificar el recorrido de los bucles:

- `exit` finaliza el script devolviendo un código al sistema.
- `break` termina la iteración actual y sale del bucle.
- `continue` salta a la siguiente iteración sin ejecutar el resto del bloque.

## 2. Sintaxis con anotaciones

```bash
exit CODIGO        # CODIGO suele ser 0 (éxito) u otro número (error)

break              # Sale del bucle más interno
break N            # Sale de N niveles de bucles anidados

continue           # Salta a la siguiente iteración
continue N         # Salta N niveles en bucles anidados
```

## 3. Ejemplos escalados

### Ejemplo básico: finalizar un script

```bash
if [[ $# -ne 2 ]]
then
    echo "Uso: $0 origen destino"
    exit 1
fi
```

### Ejemplo intermedio: detener un `for` cuando se cumpla una condición

```bash
read -rp "Introduce un límite (1-100): " limite

for (( i = 1; i <= 100; i++ ))
do
    echo "$i"
    if [[ $i -eq limite ]]
    then
        echo "Se alcanzó el límite ($limite)."
        break
    fi
done

echo "El script continúa después del bucle."
```

### Ejemplo aplicado: omitir elementos con `continue`

```bash
for archivo in /var/log/*.log
do
    if [[ ! -s $archivo ]]
    then
        continue    # Ignora ficheros vacíos
    fi

    echo "Procesando $archivo"
    grep -q "CRITICAL" "$archivo" && echo "Alerta: $archivo tiene eventos críticos"
done
```

!!! question "Prueba tú"
    Analiza la actividad **Traza de `ejemploContinue.sh`** del dossier de ejercicios y comprueba cómo `continue` y `break` afectan al flujo del bucle.

## 4. Buenas prácticas

- Devuelve códigos de salida coherentes (`exit 0` para éxito, `exit 1` o superior para errores).
- Acompaña `break` y `continue` con comentarios si la condición no es evidente.
- Evita `break` o `continue` dentro de funciones largas: considera extraer lógica en funciones auxiliares.
- En bucles anidados, usa `break N`/`continue N` solo cuando sea imprescindible; lo normal es reestructurar el código.

## 5. Actividades rápidas

- **Actividad 1:** Escribe un script que abra un fichero y pare (`break`) al encontrar la cadena `FIN`.
- **Actividad 2:** Implementa una comprobación que termine el script (`exit 2`) si el directorio `/var/backups` no es escribible.
- **Actividad 3:** Recorre una lista de nombres y omite (`continue`) aquellos que empiecen por `test`, mostrando solo el resto.
