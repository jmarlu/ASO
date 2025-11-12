---
search:
  exclude: true
---
# Examen de comandos

## Instrucciones
- Tiempo disponible: 2 horas
- Cada comando debe ejecutarse en una única línea
- Se pueden utilizar pipes (|), redirecciones (>, >>) y operadores
- Los comandos deben funcionar en cualquier distribución Linux
- La puntuación total es de 10 puntos

## Ejercicios

### 1. Gestión de Usuarios (2.5 puntos)
Crea un comando que muestre ÚNICAMENTE el UID y nombre del usuario en el sistema.

**Requisitos:**
- Solo debe mostrar dos columnas: UID y nombre de usuario
- Debe estar ordenado por **UID de menor a mayor**
- No debe mostrar cabeceras ni información adicional

**Comandos útiles:**
- `cut` - Extrae secciones de cada línea de un archivo
- `sort` - Ordena líneas de texto
- `tr` - Traduce o elimina caracteres

!!! Note:

      No se puede utilizar ni awk ni sed 

**Ejemplo de salida esperada:**
```
1000 julio
1001 maria
1002 pedro
```

### 2. Búsqueda de Correos Electrónicos (2.5 puntos)
Desarrolla un comando que busque todos los correos electrónicos en el sistema de ficheros.

**Requisitos:**
1. Crear un fichero de prueba:
   - Nombre: `emails.txt`
   - Contenido: Añadir al menos un correo electrónico válido
   - Ubicación: Directorio home del usuario

2. Comando de búsqueda:
   - Debe buscar el patrón usuario@dominio.extension
   - La búsqueda debe realizarse en todo el sistema
   - Ignorar errores de permisos
   - Mostrar solo las rutas de los archivos que contienen correos

**Comandos útiles:**
- `find`
- `egrep`

**Ejemplo de salida esperada:**
```
/home/usuario/emails.txt
/etc/config/mail.conf
```

### 3. Gestión de Ficheros y Permisos (2.5 puntos)
Crea un comando que cuente ficheros específicos del sistema según varios criterios.

**Requisitos:**
- Buscar ficheros que cumplan TODAS estas condiciones:
  * Pertenezcan a tu usuario actual
  * Tamaño superior a 200KB
  * Tengas permiso de escritura sobre ellos

- Gestión de salida:
  * El número total de ficheros → fichero `res3`
  * Mensajes de error → fichero `err3`
  * No mostrar nada por pantalla
  * Ambos ficheros deben crearse en el directorio actual

**Comandos útiles:**
- `find` - Busca archivos en una jerarquía de directorios
- `wc` - Imprime el número de líneas, palabras y bytes

**Ejemplo del contenido esperado en res3:**
```
42
```

### 4. Monitorización de Procesos (2.5 puntos)
Crea un comando que muestre los 5 procesos que más memoria RAM están consumiendo.

**Requisitos:**
- Mostrar solo: PID, usuario, %RAM y nombre del proceso
- Ordenar por uso de RAM (de mayor a menor)
- Excluir procesos del sistema (root)

**Comandos útiles:**
- `ps` - Reporta el estado de los procesos
- `head` - Muestra las primeras líneas


**Ejemplo de salida esperada:**
```
  PID USER     %MEM COMMAND
 3721 julio    4.2  firefox
 2514 julio    3.1  chrome
 1852 julio    2.8  code
 4012 julio    2.1  thunderbird
 3301 julio    1.9  nautilus
```

## Ayudas generales:

1. **Herramientas de ayuda:**

      - `man comando` - Manual del comando
      - `comando --help` - Ayuda rápida
      - `info comando` - Información detallada

2. **Consejos de ejecución:**

      - Prueba primero en directorios pequeños
      - Usa Control+C para detener un comando

3. **Técnicas útiles:**

      - Redirección de salida: `>`, `>>`
      - Redirección de error: `2>`
      - Tuberías: `|`
      - Variables de entorno: `$USER`, `$HOME`

## Criterios de Evaluación

   - Precisión del comando (40%)
   - Eficiencia de la solución (30%)
   - Gestión correcta de errores (20%)
   - Formato de salida correcto (10%)