# Actividades de la UD2

## Entrega y evaluación

- Entrega única por actividad (PDF/MD) con capturas que demuestren cada paso.
- Incluye comandos usados, configuración aplicada y validación (estado de servicios, logs, salidas de `systemctl` o `reg query`).
- Rúbrica orientativa: 40 % exactitud técnica, 30 % documentación clara y reproducible, 20 % validación, 10 % orden y limpieza.
- Actividades 1 y 2 son obligatorias; Actividades 3 son de refuerzo/extra.

## Actividad 1 (obligatoria)

Objetivo: practicar procesos, servicios y cron/systemd según la teoría.

1. Completa en Aules la **Relación 3-I de tareas y procesos**: resume los 3 comandos que más hayas usado (`ps`, `top`, `kill`, `nice`, etc.) y una captura donde se vea el PID y estado de un proceso real.
2. Completa en Aules la **Relación 3-II de instalación**: indica un ejemplo de instalación y desinstalación con `apt` (o Winget en Windows) y captura de verificación.
3. Completa en Aules la **Relación 3-III de servicios**: escoge un servicio en Linux (`systemctl status ...`) y otro en Windows (services.msc), captura estado y cómo lo detendrías/activarías.

## Actividad 2 (obligatoria)

Objetivo: aplicar administración de software, servicios y tareas programadas en ambos sistemas.

1. **Wine en GNU/Linux**
   - Añade el repositorio `ppa:wine/wine-builds`, instala Wine y muestra cómo listar y eliminar repositorios (`add-apt-repository --remove ...` o edición en `/etc/apt/sources.list.d`).
2. **Servicios en Windows 10 Pro**
   - Deshabilita: Informe de errores, Seguimiento de diagnósticos, Asistente de compatibilidad de programas, Registro remoto, Geolocalización y Administrador de mapas descargados.
   - Evidencia: captura "Tipo de inicio" en `services.msc` tras reiniciar.
3. **Nginx en contenedor LXD**
   - Lanza un contenedor Ubuntu con LXD, instala nginx desde repositorios, identifica el servicio (`nginx.service`) y desactiva su arranque automático (`systemctl disable nginx`). Verifica tras reiniciar el contenedor.
   - Apóyate en la guía de contenedores (`ContenedoresLXC.md`, sección LXD) para red, autostart y comprobaciones.
4. **Copia horaria con cron/Task Scheduler**
   - GNU/Linux: programa en `crontab` o `/etc/crontab` una copia de `/mnt/datos` a `/mnt/respaldo` cada hora con `cp` o `rsync`. Incluye montaje o entrada en `/etc/fstab` si procede.
   - Windows: tarea programada que copie `C:\Datos` a `D:\Respaldo` cada hora con `copy`. Muestra historial de la tarea.
5. **Backup diario con systemd**
   - Crea `backup-logs.service` y `backup-logs.timer` para añadir los archivos de `/var/log` a `~/copia_de_seguridad/backup.tar.gz` cada día. Incluye ambos archivos y salida de `systemctl list-timers`.
6. **Actualizaciones desatendidas**
   - Configura solo actualizaciones de seguridad en Ubuntu Server con `unattended-upgrades`; muestra fragmento de `/etc/apt/apt.conf.d/50unattended-upgrades` y log de ejecución. En Windows, muestra la política de Windows Update configurada.
7. **Registro de Windows**
   - Cambios: desactivar notificaciones UAC, añadir `notepad.exe` al inicio, mover carpetas especiales a otra partición, deshabilitar USB.
   - Evidencia antes/después desde RegEdit o `reg add/reg query`, más verificación funcional.

## Actividades 3 (refuerzo)

1. **Conversión de paquetes**
   - Descarga Firefox en formato RPM en Ubuntu Desktop, conviértelo con `alien -d`, instala el `.deb` y comenta por qué convertir. Indica dos métodos alternativos de instalación.
2. **Programación de script en cron**
   - Descarga el script de Moodle, concédelo con `chmod 777 script.sh` (explica por qué no es buena práctica y qué permiso usarías realmente).
   - Añade en `sudo crontab -e`: `* * * * * ~/Escritorio/script.sh`. Explica qué significa cada asterisco y ajusta para ejecutarse cada minuto entre las 8 y las 20 todos los días.
   - Verifica funcionamiento y adjunta salida de `grep script.sh /var/log/syslog` o similar.
