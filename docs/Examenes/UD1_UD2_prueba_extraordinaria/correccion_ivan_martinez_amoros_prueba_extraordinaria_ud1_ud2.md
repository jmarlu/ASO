---
search:
  exclude: true
---

# Corrección - Prueba extraordinaria UD1 + UD2

**Alumno:** Ivan Martinez Amoros  
**Entrega revisada:** `/home/julio/Documentos/ASO/docs/Examenes/UD1_UD2_prueba_extraordinaria/extra_ud1_ud2_Ivan/`  
**Examen de referencia:** `examen_prueba_extraordinaria_ud1_ud2.pdf`  
**Fecha de corrección:** 2026-06-29

## Calificación propuesta

**2,70 / 10**

| Parte | Puntuación máxima | Puntuación obtenida |
|---|---:|---:|
| Parte 1 - Preparación LXD/LXC | 1,00 | 0,35 |
| Parte 2 - Datos y scripting en bash | 5,00 | 0,75 |
| Parte 3 - Paquetería y servicios | 2,00 | 1,05 |
| Parte 4 - Procesos y tareas programadas | 1,00 | 0,35 |
| Parte 5 - Systemd timer y empaquetado | 1,00 | 0,20 |
| **Total** | **10,00** | **2,70** |

## Parte 1 - Preparación del laboratorio LXD/LXC

**Puntuación: 0,35 / 1,00**

Se entrega `resultados/lxc.txt` con algunos comandos relacionados con LXC:

- Creación de un contenedor con `lxc launch ubuntu:24.04 examen`.
- Configuración de CPU con `limits.cpu 1`.
- Intento de configuración de memoria.
- Una IP anotada: `10.102.89.9/24`.
- Creación de un snapshot.

Incidencias:

- El contenedor se llama `examen`, no `extra-ud1ud2` como pedía el enunciado.
- La memoria indicada es `798MB`, no `768MB`.
- El autostart contiene una errata: `exmaen` en lugar de `examen`, por lo que esa configuración no queda demostrada.
- No se aporta salida real de `lxc list`, `lxc info` ni comprobaciones de configuración.
- El snapshot se llama `snapshot1`, no `base-extra`.
- La estructura principal aparece en la entrega, pero no queda bien documentada dentro de `lxc.txt`.

## Parte 2 - Datos y scripting en bash

**Puntuación: 0,75 / 5,00**

El fichero `datos/servicios.txt` está creado correctamente y coincide con el contenido pedido.

El script `scripts/auditoria_servicios.sh` tiene permisos de ejecución y no tiene errores de sintaxis con `bash -n`, pero no resuelve la auditoría solicitada. Su contenido se limita a validar parcialmente los argumentos, comprobar una ruta incorrecta y hacer un `cat` del fichero.

Incidencias importantes:

- No se validan correctamente `umbral_disco` y `umbral_ram` como enteros.
- La validación de `estado_esperado` está invertida: muestra error cuando el tercer argumento no está vacío.
- Usa la ruta absoluta `/extra_ud1_ud2/datos/servicios.txt`, que no coincide con `~/extra_ud1_ud2/datos/servicios.txt`.
- No ignora líneas vacías o comentarios de forma controlada.
- No valida que cada línea útil tenga 7 campos.
- No detecta errores de datos en `xx`, `yy` u `ochenta`.
- No genera alertas `DISCO BAJO`, `RAM BAJA` ni `ESTADO INCORRECTO`.
- No clasifica servicios en `web`, `datos`, `copias`, `red` u `otros`.
- No genera `resultados/informe_servicios.csv`.
- No calcula la RAM mínima ni muestra el resumen final.
- No se entregan `auditoria_20_4.txt`, `auditoria_30_8.txt` ni `auditoria_script.txt`.

Al ejecutar el script fuera del contenedor entregado con `20 4 activo`, falla por ruta inexistente:

```text
cat: /extra_ud1_ud2/datos/servicios.txt: No such file or directory
```

Desglose:

| Criterio | Máximo | Obtenido |
|---|---:|---:|
| `servicios.txt` correcto | 0,50 | 0,50 |
| Validación de argumentos y existencia del fichero | 0,75 | 0,10 |
| Lectura del fichero ignorando comentarios y líneas vacías | 0,50 | 0,05 |
| Detección de errores de formato y datos | 0,75 | 0,00 |
| Alertas de disco, RAM y estado | 0,75 | 0,00 |
| Clasificación del tipo de servicio | 0,50 | 0,00 |
| Generación de `informe_servicios.csv` | 0,50 | 0,00 |
| Mínima RAM y resumen final | 0,50 | 0,00 |
| Permisos, comentarios y organización | 0,25 | 0,10 |

## Parte 3 - Paquetería y servicios

**Puntuación: 1,05 / 2,00**

`resultados/servicios.txt` incluye evidencias parciales de instalación de `nginx`, `curl` y `htop`, estado de `nginx`, registros del servicio, escucha en el puerto 80, estado de unidades `nginx` y `cron`, prueba con `curl localhost` y deshabilitación de `nginx`.

Incidencias:

- La evidencia de `apt update` no aparece completa.
- No se incluyen paquetes actualizables.
- No aparecen consultas completas como `apt show nginx`, `apt-cache depends nginx`, `apt show curl` o `dpkg -L nginx`.
- No se aporta el objetivo por defecto del sistema.
- La página web contiene solo el texto principal y además con errata: `Practica extraordianria UD1 UD2`.
- No aparece el hostname del contenedor.
- No aparece la fecha generada por comando.
- Se ve `systemctl disable nginx`, pero no se documenta claramente el reinicio manual posterior ni una segunda comprobación completa de escucha y acceso web.

## Parte 4 - Procesos y tareas programadas

**Puntuación: 0,35 / 1,00**

`resultados/procesos.txt` contiene evidencias parciales de los tres procesos `sleep`, modificación de prioridad del `sleep 500`, finalización de `sleep 700` con `SIGTERM`, finalización de `sleep 900` con `SIGKILL` y comprobación final donde solo aparece el `grep`.

Incidencias:

- No se guardan claramente los PID de los tres procesos desde el inicio; faltan evidencias limpias de `jobs -l`.
- La evidencia de señales disponibles con `kill -l` no aparece.
- La modificación de nice se documenta con una captura textual de `top`, pero no con comandos reproducibles.
- No se entrega `cron/crontab.txt`.
- La carpeta `cron/` está vacía.
- No hay evidencias de las tres tareas programadas pedidas.

## Parte 5 - Systemd timer y empaquetado final

**Puntuación: 0,20 / 1,00**

Se ha localizado un paquete `extra_ud1_ud2_entrega.tar.gz` en la carpeta del examen. El contenido del paquete coincide con la entrega revisada y contiene carpetas `scripts/`, `resultados/`, `datos/` y `cron/`.

Incidencias:

- No se entrega `resumen-extra.service`.
- No se entrega `resumen-extra.timer`.
- No se entrega `resultados/timer.txt`.
- No hay evidencias de `systemctl daemon-reload`, habilitación, arranque ni ejecución manual del servicio.
- No hay evidencia de registros del servicio ni de `systemctl cat`.
- La carpeta `cron/` está incluida, pero está vacía.

## Observaciones finales

La entrega demuestra que se inició el laboratorio y que se realizaron algunas partes prácticas de servicios y procesos. Sin embargo, falta la parte central del examen: el script de auditoría no implementa la lógica pedida y no se entregan las salidas obligatorias de la Parte 2. También falta por completo la configuración del timer de systemd y las tareas de cron.

Para mejorar esta entrega, lo prioritario sería:

- Rehacer `auditoria_servicios.sh` con lectura línea a línea, validaciones, alertas, CSV, resumen y mínima RAM.
- Ejecutar el script con `20 4 activo` y `30 8 activo` y guardar ambas salidas.
- Completar `crontab.txt`.
- Crear y validar `resumen-extra.service` y `resumen-extra.timer`.
- Guardar evidencias reales de LXC con salidas de comandos, no solo comandos escritos.
