# Operadores lógicos en Bash

## 1. Descripción

Los operadores lógicos permiten combinar varias condiciones dentro de `[[ ... ]]` o `(( ... ))`. Con ellos puedes crear reglas más expresivas, tomar decisiones complejas y controlar el flujo de tus scripts.

## 2. Sintaxis con anotaciones

| Operador | Significado                                        | Ejemplo |
| :------: | -------------------------------------------------- | ------- |
| `&&`     | AND: ambas condiciones deben ser verdaderas        | `[[ -d $dir && -w $dir ]]` |
| `||`     | OR: al menos una condición debe ser verdadera      | `[[ $rol = "admin" || $rol = "operador" ]]` |
| `!`      | NOT: invierte el resultado de la condición         | `[[ ! -f $conf ]]` |

También puedes usar `(( ... ))` para evaluaciones aritméticas con operadores similares a los de C (`<`, `>`, `==`, `&&`, `||`).

## 3. Ejemplos escalados

### Ejemplo básico: directorio listo para copias

```bash
backup_dir=/var/backups

if [[ -d $backup_dir && -w $backup_dir ]]
then
    echo "Preparado para crear copias en $backup_dir."
else
    echo "No se puede escribir en $backup_dir."
fi
```

### Ejemplo intermedio: combinación de múltiples condiciones

```bash
read -rp "Número de vidas: " vidas
read -rp "Número de continues: " continues

if [[ $vidas -le 0 && $continues -le 0 ]]
then
    echo "Game Over."
elif [[ $vidas -le 0 || $continues -le 0 ]]
then
    echo "Última oportunidad."
else
    echo "Puedes seguir jugando."
fi
```

### Ejemplo aplicado: credenciales con validación compuesta

```bash
read -rp "Usuario: " usuario
read -rsp "Contraseña: " pass
echo

if [[ ( $usuario = "admin" && $pass = "4dm1n!" ) || ( $usuario = "soporte" && $pass = "s0p0rt3" ) ]]
then
    echo "Acceso autorizado."
else
    echo "Credenciales incorrectas."
fi
```

!!! question "Prueba tú"
    Pon en práctica los operadores lógicos con la actividad **Menú interactivo de red** del bloque Case y While: combina condiciones para validar opciones y comandos disponibles.

## 4. Buenas prácticas

- Agrupa con paréntesis `()` para dejar clara la prioridad de evaluación.
- Usa `[[ ... ]]` (no `[`), porque admite operadores `&&` y `||` sin necesidad de escapado.
- Prefiere comparadores dobles (`==`, `!=`) para cadenas dentro de `[[ ]]` y operadores numéricos clásicos (`-lt`, `-gt`) cuando estés en `[[ ]]`.
- En `(( ... ))`, no pongas `$` delante de las variables y documenta el objetivo del cálculo.

## 5. Actividades rápidas

- **Actividad 1:** Escribe una condición que verifique que un fichero existe y no está vacío antes de procesarlo.
- **Actividad 2:** Comprueba si un servicio está activo (`systemctl is-active`) **o** si el puerto está escuchando (`ss -ltn`). Lanza un aviso si ambos fallan.
- **Actividad 3:** Usa `(( ... ))` para determinar si un número es múltiplo de 3 **y** par antes de añadirlo a una lista.
