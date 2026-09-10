---
search:
  exclude: true
---

# Corrección - Prueba extraordinaria UD1 + UD2

**Alumno:** Álvaro Morales Madrid  
**Entrega revisada:** `/home/julio/Descargas/extra_ud1_ud2/`  
**Examen de referencia:** `examen_prueba_extraordinaria_ud1_ud2.pdf`  
**Fecha de corrección:** 2026-06-29

## Calificación propuesta

**5,75 / 10**

| Parte | Puntuación máxima | Puntuación obtenida |
|---|---:|---:|
| Parte 1 - Preparación LXD/LXC | 1,00 | 0,40 |
| Parte 2 - Datos y scripting en bash | 5,00 | 3,20 |
| Parte 3 - Paquetería y servicios | 2,00 | 1,40 |
| Parte 4 - Procesos y tareas programadas | 1,00 | 0,60 |
| Parte 5 - Systemd timer y empaquetado | 1,00 | 0,15 |
| **Total** | **10,00** | **5,75** |

## Parte 1 - Preparación del laboratorio LXD/LXC

**Puntuación: 0,40 / 1,00**

Se entrega `resultados/lxc.txt` con el contenedor `extra-ud1ud2` en estado `RUNNING` y con IP `10.245.247.47`. También se entrega la estructura principal de carpetas `scripts/`, `resultados/`, `datos/` y `cron/`.

Faltan evidencias pedidas en el enunciado:

- No aparece la creación del contenedor ni el comando de arranque.
- No aparece la comprobación de `limits.memory`.
- No aparece la comprobación de `limits.cpu`.
- No aparece la comprobación de `boot.autostart`.
- No aparece evidencia del snapshot `base-extra`.

## Parte 2 - Datos y scripting en bash

**Puntuación: 3,20 / 5,00**

El fichero `datos/servicios.txt` está creado correctamente y coincide con el contenido pedido. El CSV `resultados/informe_servicios.csv` contiene la cabecera y las cinco líneas válidas esperadas:

- `web02`
- `app02`
- `db02`
- `backup02`
- `dns02`

Las salidas `auditoria_20_4.txt` y `auditoria_30_8.txt` contienen correctamente las alertas principales de disco, RAM, estado y errores de datos. Sin embargo, no incluyen el resumen final ni la línea de mínima RAM, que eran obligatorios.

Incidencias importantes:

- El script entregado `scripts/auditoria_servicios.sh` no pasa validación sintáctica con `bash -n`.
- La línea final del resumen está cortada:

```bash
echo "Resumen: $n_validos validos, $n_formato formato, $n_datos datos, $n_disco disco, $n_ram ram, $n_estado >
```

- Por ese corte, el script final entregado no es ejecutable correctamente.
- `resultados/auditoria_script.txt` está vacío, aunque el enunciado pedía guardar una copia del script.
- Los mensajes de error de validación de argumentos y fichero no coinciden con el formato orientativo del solucionario.
- El script usa rutas fijas `/home/ubuntu/...`; funciona si ese es el usuario real del contenedor, pero es menos robusto que usar `$HOME`.
- El script no incluye comentarios breves en las partes principales.

Desglose:

| Criterio | Máximo | Obtenido |
|---|---:|---:|
| `servicios.txt` correcto | 0,50 | 0,50 |
| Validación de argumentos y existencia del fichero | 0,75 | 0,35 |
| Lectura del fichero ignorando comentarios y líneas vacías | 0,50 | 0,45 |
| Detección de errores de formato y datos | 0,75 | 0,65 |
| Alertas de disco, RAM y estado | 0,75 | 0,70 |
| Clasificación del tipo de servicio | 0,50 | 0,45 |
| Generación de `informe_servicios.csv` | 0,50 | 0,50 |
| Mínima RAM y resumen final | 0,50 | 0,00 |
| Permisos, comentarios y organización | 0,25 | 0,10 |

## Parte 3 - Paquetería y servicios

**Puntuación: 1,40 / 2,00**

`resultados/servicios.txt` incluye evidencias de `apt update`, paquetes actualizables, paquetes instalados relacionados con `nginx`, `curl` y `htop`, información de paquetes, dependencias de `nginx`, ficheros del paquete, estado de `nginx`, escucha en red, objetivo por defecto, estado de `nginx` y `cron`, y prueba con `curl`.

Incidencias:

- No se ve claramente la salida de `apt install`.
- La página web contiene:

```html
<p>Hostname: $(hostname)</p>
<p>Fecha: $(date)</p>
```

Esto deja los comandos como texto literal. El enunciado pedía el hostname y la fecha generados por comandos, no las expresiones sin ejecutar.

- No se aporta evidencia clara de haber deshabilitado el arranque automático de `nginx`; en la evidencia sigue apareciendo `enabled`.
- No se aprecia una comprobación posterior completa tras deshabilitar y reiniciar manualmente `nginx`.

## Parte 4 - Procesos y tareas programadas

**Puntuación: 0,60 / 1,00**

El fichero `cron/crontab.txt` contiene las tres tareas programadas pedidas:

```cron
*/20 * * * * date >> /home/ubuntu/extra_ud1_ud2/cron/fechas.log
10 * * * * uptime >> /home/ubuntu/extra_ud1_ud2/cron/carga.log
30 23 * * * hostname >> /home/ubuntu/extra_ud1_ud2/cron/host.log
```

También existen evidencias de ejecución para `fechas.log` y `carga.log`.

Incidencias en procesos:

- `resultados/procesos.txt` mezcla comandos escritos con salidas, pero no documenta de forma limpia la ejecución.
- Los primeros `PIDs` aparecen vacíos.
- No se ve una relación correcta de `jobs -l` con los tres procesos `sleep`.
- Hay errores de escritura de comandos, por ejemplo `renice +10 $PID500enice...`.
- La comprobación final muestra todavía un `sleep 500`, por lo que no queda demostrado que no queden procesos lanzados para la prueba.

## Parte 5 - Systemd timer y empaquetado final

**Puntuación: 0,15 / 1,00**

Se entregan `cron/resumen-extra.service` y `cron/resumen-extra.timer`, pero el servicio está cortado y tiene comillas sin cerrar:

```ini
ExecStart=/bin/bash -c 'date >> /home/ubuntu/extra_ud1_ud2/cron/resumen.log; hostname >> /root/extra_ud1_ud2/cron/re>
```

La propia evidencia de `resultados/timer.txt` confirma el fallo:

```text
Unbalanced quoting
Unit configuration has fatal error
Active: inactive (dead)
0 timers listed.
```

Por tanto, el timer no queda funcionando. Tampoco se ha localizado el paquete final `extra_ud1_ud2_entrega.tar.gz` en la entrega revisada.

## Observaciones finales

La entrega demuestra trabajo real en el contenedor y consigue una parte importante de la práctica, especialmente en el fichero de datos, el CSV y las salidas principales del script. Los errores que más penalizan son:

- El script final entregado está roto sintácticamente.
- Faltan el resumen y la mínima RAM en las salidas de auditoría.
- `auditoria_script.txt` está vacío.
- El servicio `systemd` está truncado y el timer no funciona.
- Las evidencias de LXD/LXC, procesos y empaquetado final están incompletas.

Para mejorar esta entrega, lo prioritario sería corregir el cierre del `echo` final del script, volver a ejecutar las dos auditorías, guardar bien `auditoria_script.txt`, rehacer el `resumen-extra.service` completo y regenerar el `.tar.gz` final.
