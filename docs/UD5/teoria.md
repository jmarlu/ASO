# Automatizar tareas en GNU/Linux

## 1. Qué debemos decidir antes de programar

Una tarea automática tiene un objetivo, una frecuencia, una cuenta de ejecución, entradas, salidas y una forma de comprobar el resultado. Ejemplo: cada día a las 08:00, la cuenta `asoauto` genera un informe en `/var/lib/aso-ud5/informes/ultimo.txt`.

Antes de automatizar, ejecuta el comando manualmente con **la misma cuenta** que usará el planificador. Evita preguntas interactivas y dependencias del directorio actual.

| Información | Comando | Interpretación |
|---|---|---|
| Sistema y núcleo | `uname -r`, `cat /etc/os-release` | Versión que debes documentar |
| Carga | `uptime` | Carga media; no es un porcentaje de CPU |
| Memoria | `free -h` | Observa `available`, no solo `free` |
| Disco | `df -h /` | Espacio del sistema de archivos raíz |
| Procesos | `ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu` | Fotografía del consumo |
| Servicios fallidos | `systemctl --failed` | Fallos conocidos por systemd |
| Errores recientes | `journalctl -p err --since '-24 hours'` | Solo los mensajes visibles para la cuenta |

`/proc` y `/sys` exponen información del núcleo y dispositivos; no son directorios de datos ordinarios para una copia de seguridad. Un inventario útil registra versiones, servicios y rutas, sin incluir contraseñas.

## 2. El contrato de un script

- Argumentos comprobados y rutas absolutas.
- Entrada sin interacción; salida normal por stdout y errores por stderr.
- Código 0 para éxito y distinto de cero para fallo. Nuestros scripts reservan 2 para uso incorrecto y 75 para una ejecución ya en curso.
- `PATH` explícito y `umask 077` para generar archivos privados.
- Script instalado por root con modo 755; datos de salida escribibles por la cuenta del servicio.

`set -euo pipefail` ayuda a detectar fallos, variables sin definir y errores en tuberías, pero no sustituye el tratamiento explícito de errores. Dentro de `if` se puede comprobar una orden que legítimamente devuelve un estado distinto de cero.

```bash
if systemctl is-active --quiet nginx.service; then
    echo 'Servicio activo'
else
    echo 'Servicio inactivo o no disponible' >&2
    exit 1
fi
```

Un archivo temporal y un `mv` final evitan publicar un informe incompleto. El laboratorio proporciona scripts comentados para inspeccionar estas decisiones.

## 3. cron: tareas periódicas

`crontab -e` edita la tabla de la cuenta actual; `crontab -l` la consulta. `sudo crontab -e` edita la de root. `/etc/crontab` y los archivos de `/etc/cron.d/` son tablas del sistema y llevan una columna de usuario adicional.

```text
# Tabla de usuario: minuto hora día-mes mes día-semana comando
0 8 * * 1-5 /ruta/absoluta/informe.sh /ruta/absoluta/salida
# Tabla del sistema: añade el usuario antes del comando
0 8 * * 1-5 asoauto /usr/local/lib/aso-ud5/informe.sh /var/lib/aso-ud5/informes
```

| Calendario | Cuándo se ejecuta |
|---|---|
| `*/10 * * * *` | Minutos 0, 10, 20, 30, 40 y 50 de cada hora |
| `5 * * * Sun` | Minuto 5 de cada hora del domingo |
| `30 2 * * *` | Todos los días a las 02:30 |
| `0 8 * * 1-5` | A las 08:00 de lunes a viernes |
| `0 12 16 * Wed` | A las 12:00 los días 16 y los miércoles |

Cuando día del mes y día de semana están restringidos, cron tradicional acepta **cualquiera de los dos**. Si necesitas que se cumplan ambos, añade una condición dentro del script. El shell predeterminado es `sh`; el shebang de un script ejecutable permite que su contenido se interprete con Bash. Véase el [manual de crontab de Debian](https://manpages.debian.org/trixie/cron/crontab.5.en.html).

El entorno no es el de tu terminal: no presupongas alias, variables de sesión ni rutas relativas. `>> archivo 2>&1` añade stdout y stderr al registro. En las órdenes de crontab, `%` tiene un significado especial; mueve expresiones como `date +%F` al script. Las tareas perdidas durante un apagado no se recuperan automáticamente con cron ordinario.

## 4. at: una ejecución puntual

```bash
echo '/usr/bin/date >> /tmp/aso-at-fecha.txt' | at now + 2 minutes
atq
# Sustituye 12 por el identificador real mostrado por atq.
at -c 12
atrm 12
```

`atd` debe estar activo. `at -c` permite inspeccionar la orden y el entorno capturado antes de su ejecución. Para datos reales utiliza un directorio privado, como en el laboratorio.

## 5. systemd: separar qué hacer de cuándo hacerlo

La unidad `.service` describe la tarea; la unidad `.timer` con el mismo nombre la activa. `Type=oneshot` sirve para una orden que termina. `ExecStart=` no interpreta automáticamente tuberías, `>>` ni `~`: usa un script.

| Directiva | Uso |
|---|---|
| `User=asoauto` | Cuenta del servicio del sistema |
| `OnCalendar=*-*-* 08:00:00` | Calendario de reloj |
| `OnBootSec=2min` | Primer disparo relativo al arranque |
| `OnUnitActiveSec=5min` | Intervalo desde la última activación |
| `Persistent=true` | Recuperar un disparo de calendario perdido al reactivar el timer |
| `WantedBy=timers.target` | Permitir habilitar el timer en el arranque |

La recuperación persistente provoca una activación si se perdió alguna, no reproduce todas las ejecuciones omitidas. No se aplica a temporizadores exclusivamente monotónicos. El disparo admite una ventana de precisión: no debe tratarse como un reloj de tiempo real. Un timer no inicia otra instancia de su servicio si este sigue activo. Detalles en el [manual de systemd.timer](https://manpages.debian.org/trixie/systemd/systemd.timer.5.en.html).

```bash
systemd-analyze calendar '*-*-* 08:00:00'
timedatectl
sudo systemctl daemon-reload
sudo systemctl enable --now aso-informe.timer
systemctl list-timers --all aso-informe.timer
sudo journalctl -u aso-informe.service -n 20 --no-pager
systemctl show aso-informe.service -p Result -p ExecMainStatus
```

Un servicio oneshot puede quedar `inactive (dead)` después de terminar correctamente. Consulta el resultado y el archivo generado. `daemon-reload` recarga definiciones; no ejecuta la tarea. Habilitamos el timer, no el servicio oneshot.

## 6. Fiabilidad, permisos y conservación

`flock` impide que dos ejecuciones cooperantes escriban simultáneamente sobre los mismos resultados. Deben bloquear el mismo archivo, cuyo directorio estará protegido. Nuestro contrato devuelve 75 cuando no obtiene el bloqueo: decide si esa omisión es aceptable o requiere investigar una tarea atascada.

La cuenta `asoauto` no necesita sudo. Para leer todos los registros del sistema se le concede el grupo `systemd-journal`; ese permiso permite leer más información y debe justificarse. La práctica de cuentas se ejecuta como root mediante un script separado, fijo y no modificable por `asoauto`.

La copia del laboratorio conserva cinco archivos completos. Solo elimina copias antiguas después de crear y verificar la nueva. Guardarlas en el mismo disco permite practicar recuperación de archivos, pero no protege frente a la pérdida de ese disco. Para un servidor real habrá que definir un destino independiente, capacidad y política de conservación.

Si el origen cambia durante `tar`, la copia puede fallar y no se publica como correcta. Bases de datos y servicios con datos vivos necesitan mecanismos de copia específicos. La prueba con `tar -t` comprueba que el archivo se puede leer; la restauración y comparación comprueban el contenido esperado.

## 7. Planificación gráfica en Linux

[KCron](https://apps.kde.org/kcron/) es una interfaz gráfica para cron. Permite crear y modificar tareas, que después puedes inspeccionar mediante `crontab -l`. Trabajaremos con la cuenta del alumno en una VM Kubuntu; la interfaz no elimina la necesidad de comprobar permisos, calendario y resultados.

## 8. Diagnóstico por orden

1. ¿La máquina estaba encendida y el reloj/zona horaria eran correctos?
2. ¿El planificador estaba activo y la tarea habilitada?
3. ¿La orden funciona manualmente con la cuenta de ejecución?
4. ¿Existen el origen, el ejecutable y el destino? ¿Sus permisos permiten trabajar?
5. ¿Qué muestran stderr, journal y el código de salida?
6. ¿El resultado es nuevo, completo y restaurable cuando corresponde?

La [práctica guiada](laboratorio.md) aplica este recorrido. Windows se reserva como ampliación: traducir una tarea al Programador de tareas, sin sustituir las evidencias Linux.
