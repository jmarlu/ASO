# Revisión y adaptación de fundamentos GNU/Linux

Fecha: 10 de septiembre de 2026.

Origen: `/home/julio/Documentos/ISO/ISONew/UD1/docs/UD2`.

Destino de preparación: `preparacion/fundamentos-linux/`. Los originales de ISO se conservan. No se ha modificado la navegación de ASO para integrar este bloque.

## Alcance y decisiones

Se ha revisado el contenido completo de los siete temas seleccionados para el inicio de Linux: terminal, directorios, archivos, permisos, redirecciones, filtros y búsquedas, además de las actividades originales. Se han redactado versiones adaptadas con ejemplos sobre un mismo entorno de práctica.

`AdminMemoriaSecundaria.md` y `gestorArranque.md` quedan fuera del bloque de fundamentos según el alcance acordado. No se presentan como auditados técnicamente por esta adaptación. Tampoco se trasladan sus prácticas de particionado, fstab y arranque dual. El material resultante no depende de sus imágenes ni del curso Moodle de origen.

## Incidencias corregidas

| Original | Problema encontrado | Adaptación |
|---|---|---|
| IntroTerminal | Sintaxis general presentada como `bash comando...` | Orden directa y distinción entre shell y programa |
| IntroTerminal | Confusión entre tilde, atajos y privilegios del prompt | Expansión de `~` e identidad comprobada con id |
| IntroTerminal | Negación `!` explicada sin contexto de patrón | Uso de `[!ab]` y separación de glob/regex |
| IntroTerminal | Afirmaciones absolutas sobre exit y Ctrl+C/D/Z | Efectos habituales y sus límites |
| EstructuraDirectorios | Toda ruta descrita como si fuera absoluta | Diferenciación explícita de rutas relativas |
| EstructuraDirectorios | `/mnt` descrito como montaje de volúmenes fijos | Montajes temporales; ampliación de /var, /run, /proc y /sys |
| EstructuraDirectorios | Directorios binarios asumidos independientes | Comprobación de enlaces en jerarquías /usr unificadas |
| gestionArchivos | 255 caracteres como límite universal | Límite por sistema de archivos, habitualmente en bytes |
| gestionArchivos | Padre del archivo confundido con padre de su carpeta | Ejemplo corregido de directorio contenedor |
| gestionArchivos | touch presentado solo como creación | Diferencia entre creación y actualización de marcas |
| gestionArchivos | Tipos limitados a tres categorías y /dev confundido con drivers | Tipos visibles en ls y nodos como interfaz |
| permisosBasicos | Selección de grupo sin grupos suplementarios | Explicación de pertenencias y orden propietario/grupo/otros |
| permisosBasicos | Lectura/listado y travesía de directorios mezcladas | Tabla de r/w/x separada para archivo y directorio |
| permisosBasicos | Máscara universal 002 y resultados de 022 | Tabla coherente, consulta real y pruebas en subshell |
| permisosBasicos | 777 como ejemplo principal | Ejemplos 600/640 y directorios privados; denegación recuperable |
| redirecciones | Procesamiento de derecha a izquierda | Procesamiento de izquierda a derecha y prueba comparativa |
| redirecciones | Explicación invertida de `> archivo 2>&1` | Duplicación del destino actual del descriptor |
| redirecciones | Entradas/salidas mezcladas en el mismo bloque de código | Órdenes copiables y resultados explicados aparte |
| filtros | Circunflejo `ˆ`, comillas tipográficas y espacios ausentes | Patrones ASCII correctos y ejemplos reproducibles |
| filtros | egrep como herramienta de referencia | grep -E; grep -F para texto literal |
| filtros | Regex de IP presentada como validación | Explicación de que admite valores fuera de rango; retirada del ejercicio |
| filtros | Datos de cut y salidas no coincidentes | Inventario incluido con delimitador único y resultados verificados |
| filtros | Bytes confundidos con caracteres | wc -c y wc -m diferenciados |
| filtros | Ordenación con clave abierta y uniq impreciso | Clave de campo delimitada y duplicados adyacentes |
| filtros | Conversión con tr asumida para acentos y equivalente a expand | Ejemplos ASCII y distinción de posiciones de tabulación |
| filtros | Extracción de IP mediante posición fija de ip a | Reemplazada por análisis de registros de formato definido |
| busquedaArchivos | Guion tipográfico en find y patrón mal escapado | Guiones ASCII y patrones entre comillas |
| busquedaArchivos | Quitar guion en -perm presentado como selección de propietario | Modo exacto, todos los bits y algún bit diferenciados |
| busquedaArchivos | Rango imposible `-mtime -2 -mtime +5` | Intervalo de minutos comprobable con archivo preparado |
| busquedaArchivos | ctime confundible con creación | Cambio de estado/metadatos claramente identificado |
| busquedaArchivos | -size 100k presentado como tamaño exacto | Bytes exactos con sufijo c y explicación de redondeo |
| busquedaArchivos | Acciones amplias sobre cuentas/rutas del sistema | Consultas dentro del entorno aislado y revisión previa de selección |

## Actividades adaptadas

Las actividades originales 1 y 2 remiten a Moodle sin aportar enunciados: se sustituyen por diagnóstico, ayuda y manejo del terminal. La actividad 3 de directorios se centra en GNU/Linux. Las actividades 4–7 de discos, GRUB, dual boot y migración de home no corresponden al repaso previo a scripting.

La nueva secuencia incluye diagnóstico, terminal, rutas, permisos, redirecciones, filtros, búsquedas y un informe integrado. Se suministran dos archivos ficticios: seis equipos y ocho eventos. La guía docente aporta órdenes equivalentes, resultados esperados y criterios de corrección.

Se incluyen fallos intencionados de lectura y rutas inexistentes, seguidos de comprobación y recuperación. No se solicita sudo, acceso a datos privados, edición de cuentas ni particionado. Los nombres con espacios se trabajan como parte normal del aprendizaje.

Duración base: cinco horas; reservar entre cuatro y seis según diagnóstico y tiempo de revisión. No se ha modificado la temporalización general del módulo.

## Comprobaciones realizadas

- Ejecutada la solución real del informe, incluyendo una segunda generación: no duplica secciones; modo final 600.
- Verificados seis equipos, dos fallidos, orden numérico por memoria, grupos de servicios y recuentos de errores.
- Ejecutadas las cinco búsquedas de la solución sobre los archivos preparados en la actividad.
- Comprobada la diferencia de `> archivo 2>&1` frente a `2>&1 > archivo` con salida y error reales.
- Comprobadas denegación de lectura con modo 000 y recuperación con 600, sin root.
- Comprobados modos 600/700 con umask 077.
- Comprobados nombres con espacios y enlace simbólico relativo.
- Comprobados destinos de enlaces Markdown del borrador.
- Compilación estricta de la web independiente correcta con MkDocs 1.6.1 y Material 9.7.7.

Las pruebas se realizaron en directorios temporales. No se ha probado una clase real ni medido la duración con alumnado. Tampoco se ha automatizado la interacción de man, los atajos del terminal o las confirmaciones de rm -i.

## Referencias técnicas

- [Manual de Bash: redirecciones](https://www.gnu.org/s/bash/manual/html_node/Redirections.html): orden y duplicación de descriptores.
- [Manual GNU Grep](https://www.gnu.org/software/grep/manual/grep.pdf): patrones y sustitución de egrep por grep -E.
- [Manual GNU Findutils](https://www.gnu.org/software/findutils/manual/find.pdf): tiempos, tamaños y selección de archivos.

## Integración posterior

Cuando se incorpore el bloque, copiar las páginas de alumnado y datos a una subcarpeta de `docs/UD1/linux/`, añadir la entrada Fundamentos antes de Creación de scripts y verificar enlaces y compilación. Mantener esta revisión y la guía docente fuera del sitio público si se desea reservarlas.

También habrá que armonizar la introducción actual de scripting: `Scripts.md` afirma que 750 permite ejecutar solo al propietario y usa comillas tipográficas en órdenes. En realidad 750 permite ejecución al grupo. Este ajuste se identifica aquí, pero no se ha aplicado todavía porque la integración está pendiente.
