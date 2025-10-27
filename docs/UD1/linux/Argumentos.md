# Argumentos de scripts en Bash

## 1. Descripción

Los argumentos permiten pasar información a un script desde la línea de comandos. Se numeran empezando en `$1` y ofrecen flexibilidad para reutilizar el mismo script con datos diferentes.

## 2. Sintaxis con anotaciones

```bash
./script.sh arg1 arg2 arg3 ...
```

Dentro del script, dispones de variables especiales:

| Variable | Significado                                  |
| :------: | :------------------------------------------- |
| `$0`     | Nombre del script                            |
| `$1`…`$9`| Argumentos posicionados                      |
| `$#`     | Número total de argumentos                   |
| `$*`     | Todos los argumentos como una sola palabra   |
| `$@`     | Todos los argumentos preservando espacios    |
| `shift`  | Desplaza los argumentos: `$2` pasa a `$1`, etc. |

Usa `"$@"` cuando necesites mantener los argumentos exactamente como se passaron.

## 3. Ejemplos escalados

### Ejemplo básico: validar número de argumentos

```bash
if [[ $# -ne 2 ]]
then
    echo "Uso: $0 origen destino"
    exit 1
fi

echo "Origen: $1"
echo "Destino: $2"
```

### Ejemplo intermedio: recorrer todos los argumentos

```bash
for fichero in "$@"
do
    if [[ -e $fichero ]]
    then
        echo "$fichero existe."
    else
        echo "$fichero no encontrado."
    fi
done
```

### Ejemplo aplicado: consumir argumentos con `shift`

```bash
while [[ $# -gt 0 ]]
do
    case $1 in
        --usuario)
            usuario=$2
            shift 2
            ;;
        --grupo)
            grupo=$2
            shift 2
            ;;
        *)
            echo "Opción desconocida: $1"
            exit 2
            ;;
    esac
done

echo "Crear usuario $usuario dentro del grupo $grupo"
```

!!! question "Prueba tú"
    Completa las actividades **Propietario y permisos** y **Datos de usuario** del apartado de Argumentos: te ayudarán a practicar el uso de `"$@"`, validaciones y mensajes de uso.

## 4. Buenas prácticas

- Cita siempre los argumentos (`"$1"`, `"$@"`) para preservar espacios y caracteres especiales.
- Comprueba `"$#"` al inicio del script y ofrece un mensaje de uso claro cuando falten argumentos.
- Emplea `case` para manejar opciones con nombres largos (`--option`).
- Documenta los argumentos aceptados en la cabecera del script.

## 5. Actividades rápidas

- **Actividad 1:** Crea un script que reciba tres argumentos y verifique si el primero es un fichero, el segundo un directorio y el tercero un número.
- **Actividad 2:** Implementa un contador que acepte `-n` con un número y muestre una cuenta atrás desde ese valor.
- **Actividad 3:** Construye un script que acepte cualquier cantidad de rutas y copie cada fichero existente a un directorio `backup/` creado en la ejecución.
