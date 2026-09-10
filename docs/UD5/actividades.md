# Actividades y evaluación de UD5

Realiza las actividades en las VMs del [laboratorio](laboratorio.md). Entrega comandos y resultados legibles; una captura del temporizador activo no sustituye el archivo producido ni la explicación.

## 1. Diseñar antes de automatizar — RA3.a, h

Elige tres tareas de mantenimiento. Para cada una documenta objetivo, frecuencia, duración estimada, cuenta, entradas, destino, criterio de éxito y qué ocurriría si falla. Explica por qué no deben ejecutarse todas cada minuto.

Adapta el informe guiado para incluir versión del sistema y los cinco procesos con mayor consumo de memoria. Compara el informe original y el modificado. Indica qué datos no incluirías en una memoria compartida.

**Entrega:** tabla de tareas, script modificado e informe real.

## 2. cron y at — RA3.b, d, h

1. Completa la programación guiada de cron y at, incluida una cancelación.
2. Escribe los calendarios para: cada quince minutos; lunes a viernes a las 08:30; primer día de mes a las 03:00.
3. Explica cuándo se ejecuta `0 12 16 * Wed` y diseña una alternativa que solo se ejecute si el día 16 es miércoles.
4. Presenta la misma tarea en formato de crontab de usuario y en `/etc/cron.d/`, indicando la diferencia.
5. Ejecuta el script como `asoauto` con un entorno reducido mediante `sudo -u asoauto env -i PATH=/usr/bin:/bin /usr/local/lib/aso-ud5/informe.sh /var/lib/aso-ud5/informes`. Explica qué dependencias de tu sesión has eliminado.

**Entrega:** configuración final, fecha del resultado, logs, identificación de cuenta y trabajo puntual cancelado. Retira la tarea cron antes de activar su equivalente systemd.

## 3. Planificación gráfica con KCron — RA3.f, g, h

Usa una **VM Kubuntu 24.04 de escritorio** con tu cuenta habitual. No instales el escritorio en el servidor del laboratorio.

```bash
sudo apt update
sudo apt install cron kcron
sudo systemctl enable --now cron
mkdir -p "$HOME/ud5-gui"
printf '%s\n' "$HOME/ud5-gui"
```

1. Abre Preferencias del sistema y busca «Planificador de tareas» o «Task Scheduler». KCron es un módulo de configuración y puede no aparecer como aplicación independiente.
2. Selecciona la tabla de tu usuario, crea una tarea habilitada cada minuto y escribe `/usr/bin/date >> /home/TU_USUARIO/ud5-gui/fecha.log`. Sustituye la ruta por la ruta absoluta mostrada arriba.
3. Aplica los cambios y guarda `crontab -l`. No mantengas a la vez abierto `crontab -e` mientras editas desde KCron.
4. Espera dos disparos y demuestra dos fechas distintas en `fecha.log`.
5. Cambia el calendario a lunes a viernes a las 09:00. Comprueba su representación en `crontab -l` y después desactiva la tarea desde la interfaz.

**Entrega:** instalación, configuración inicial y final, crontab y archivo generado. Explica qué parte hace KCron y qué parte hace el demonio cron. Si el módulo no aparece, registra versión y paquete instalado y revisa con el docente el entorno; la evidencia por terminal no sustituye este criterio gráfico.

## 4. Temporizadores systemd — RA3.b, d, h

Completa los tres servicios y timers del laboratorio. Para cada uno entrega `systemctl cat`, próxima ejecución, resultado del servicio y salida real. Demuestra la recuperación de una ejecución pendiente del informe mediante la prueba de parada del timer.

Responde: ¿por qué el servicio puede estar inactivo después de terminar bien?, ¿qué ocurre si dura más que su intervalo?, ¿por qué no usamos `Persistent=true` en el timer exclusivamente monotónico?

**Entrega:** seis unidades, evidencias de ejecución y explicación de las decisiones.

## 5. Fiabilidad — RA3.c, h

Realiza las pruebas de destino sin escritura, nginx detenido y bloqueo simultáneo. Registra para cada una: síntoma, código de salida, evidencia, causa, corrección y segunda ejecución.

Comprueba además seis copias seguidas: deben conservarse cinco archivos completos, respetarse un archivo ajeno llamado `conservar.txt` y poder restaurarse el contenido esperado. Justifica el uso de un directorio exclusivo para copias.

**Entrega:** tabla de incidencias, permisos antes/después y prueba de restauración con `cmp`.

## 6. Automatizar cuentas de prueba — RA3.c, d, e, h

En la VM dedicada, crea exclusivamente dos cuentas nuevas para este ejercicio. Si los nombres ya existen, detente y aclara su procedencia antes de modificarlos.

```bash
sudo useradd -m -s /bin/bash ud5_prueba1
sudo useradd -m -s /bin/bash ud5_prueba2
sudo chage -l ud5_prueba1
sudo chage -l ud5_prueba2
```

Crea `cuentas-prueba.sh` que:

- Solo admita como argumento `--simular` o `--aplicar`.
- Utilice una lista fija con esas dos cuentas; no procese usuarios arbitrarios del sistema.
- Compruebe antes que existen ambas y que se ejecuta como root si va a aplicar cambios.
- Configure, con `chage -M 90 -W 7`, una antigüedad máxima de contraseña de 90 días y un aviso de 7 días. No activa contraseñas ni desbloquea cuentas.
- Muestre las acciones en simulación y registre cuáles aplica, sin incluir secretos.
- Devuelva error si no puede completar un cambio y admita repetirse sin crear nuevas cuentas.

Instálalo como `/usr/local/lib/aso-ud5/cuentas-prueba.sh`, propietario root y modo 750. Prueba primero `--simular`, después `--aplicar` y verifica `chage -l` en ambas cuentas. Ejecuta una segunda vez y demuestra que mantiene la política.

Finalmente, programa una aplicación puntual como root con at, redirigiendo la salida a `/root/ud5-cuentas.log`. Inspecciona el trabajo y comprueba su ejecución. El script y su directorio no deben ser modificables por usuarios sin privilegios.

**Entrega:** script, simulación, política antes/después, permisos, tarea puntual y registro. Tras guardar las evidencias y comprobar que no hay trabajos pendientes, elimina únicamente las dos cuentas creadas para el ejercicio con `userdel -r`.

## 7. Caso final: mantenimiento de un servidor de aula

Entrega una instalación reproducible con:

| Tarea | Frecuencia final | Cuenta | Resultado esperado |
|---|---|---|---|
| Informe del sistema | Diario 08:00 | asoauto | Fecha, disco, memoria, servicios fallidos y errores recientes |
| Copia de datos de prueba | Diario 02:30 | asoauto | Cinco versiones como máximo y restauración demostrada |
| Comprobación de nginx | Tras arranque y cada cinco minutos | asoauto | Incidencia cuando falla y retirada al recuperarse |

Puedes usar los scripts iniciales, pero debes explicar y defender su funcionamiento. Una ejecución manual sirve para comprobar la orden; añade al menos una ejecución automática por tarea con calendario temporal de prueba y luego restaura la frecuencia final. No alteres el reloj del sistema para acelerar pruebas.

### Estructura de entrega

```text
apellido_ud5/
  memoria.md (o PDF)
  scripts/
  systemd/
  cron-at/
  evidencias/
```

La memoria contendrá entorno/versiones, mapa de tareas, instalación, cuentas/permisos, pruebas normales, restauración, fallos y recuperación, retención, retirada del laboratorio y limitaciones. Incluye las evidencias de KCron y cuentas de las actividades 3 y 6, aunque se ejecuten fuera del caso de mantenimiento.

### Rúbrica de la unidad

| Apartado | Peso | Para obtener la puntuación completa |
|---|---:|---|
| Diseño y explicación | 10 % | Frecuencias y decisiones justificadas; interpretación correcta |
| Programación cron, at y timers | 25 % | Configuraciones válidas, ejecución automática y persistencia demostradas |
| Scripts y resultados | 20 % | Informe útil, copias restaurables y comprobación de servicio |
| Seguridad y diagnóstico | 20 % | Permisos mínimos, bloqueo y pruebas de fallo con recuperación |
| Administración de cuentas | 10 % | Simulación, aplicación puntual y verificación de política |
| Planificación gráfica | 10 % | Instalación, edición, ejecución y desactivación en KCron |
| Documentación | 5 % | Otra persona puede reproducir y retirar la instalación |

En cada apartado se aplica: 0 % del peso si falta o no funciona; 50 % si es parcial y falta una validación; 100 % si cumple lo indicado. Esta rúbrica organiza las evidencias de RA3 y no modifica su peso en el módulo. El docente debe registrar los criterios sin evidencia y pedir su subsanación; una nota global no demuestra por sí sola todos los criterios.

### Comprobación antes de entregar

- [ ] Conservo la configuración final y he retirado los calendarios acelerados.
- [ ] No hay tareas cron y timers duplicados para el mismo informe.
- [ ] Identifico la cuenta que ejecuta cada tarea.
- [ ] He restaurado una copia y comparado su contenido.
- [ ] Tengo evidencia de fallo y de recuperación.
- [ ] Demuestro KCron y administración automática de cuentas.
- [ ] No incluyo contraseñas ni información privada en la memoria.

Windows queda como **ampliación opcional**: reproducir una tarea con el Programador de tareas y comparar usuario, calendario y registro. No se exige para esta entrega.
