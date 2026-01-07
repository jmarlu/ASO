# Actividades de la UD2

## Entrega y evaluación

- Entrega única por actividad (PDF/MD) con capturas que demuestren cada paso.
- Incluye comandos usados, configuración aplicada y validación (estado de servicios, logs, salidas de `systemctl` o `reg query`).
- Rúbrica orientativa: 40 % exactitud técnica, 30 % documentación clara y reproducible, 20 % validación, 10 % orden y limpieza.


## Actividad 1 

Objetivo: practicar procesos, servicios y cron/systemd según la teoría (Ubuntu como referencia).

1. Completa en Aules la **Cuestionario de tareas y procesos**: usa `top` o `htop` (teclas 1/x/t/m) para mostrar PID, estado y carga (`load average`), y comenta brevemente un ajuste de prioridad con `nice` o `renice`.
2. Completa en Aules la **Cuestionario de instalación**: ejemplo de instalación y desinstalación con `apt`/`apt-get` (incluye `apt-cache depends` y `dpkg -L paquete` en la evidencia).
3. Completa en Aules la **Cuestionario de servicios**: escoge un servicio en Linux y otro en Windows; en Linux muestra `systemctl status --no-pager` y `journalctl -u ... -n 10`, indicando cómo lo detendrías/activarías.

## Actividad 2 

Objetivo: aplicar administración de software, servicios y tareas programadas en ambos sistemas.

1. **Wine en GNU/Linux**

      - Añade el repositorio `ppa:wine/wine-builds`, instala Wine y muestra cómo listar y eliminar repositorios (`add-apt-repository --remove ...` o edición en `/etc/apt/sources.list.d`). Incluye captura de `apt list --installed | grep wine` y de la clave en `/etc/apt/trusted.gpg.d/` si la añadiste.
   
2. **Servicios en Windows 10 Pro**
      -  Deshabilita: Informe de errores, Seguimiento de diagnósticos, Asistente de compatibilidad de programas, Registro remoto, Geolocalización y Administrador de mapas descargados.
      - Evidencia: captura "Tipo de inicio" en `services.msc` tras reiniciar.

3. **Nginx en contenedor LXD**

      - Lanza un contenedor Ubuntu con LXD, instala nginx desde repositorios, identifica el servicio (`nginx.service`) y desactiva su arranque automático (`systemctl disable nginx`). Verifica tras reiniciar el contenedor.
      - Apóyate en la guía de contenedores (`ContenedoresLXC.md`, sección LXD) para red, autostart y comprobaciones. Añade `systemctl status nginx --no-pager` y `journalctl -u nginx -n 10` como validación.

4. **Copia horaria con cron/Task Scheduler**
     - GNU/Linux: programa en `crontab` o `/etc/crontab` una copia de `/mnt/datos` a `/mnt/respaldo` cada hora con `cp` o `rsync`. Incluye montaje o entrada en `/etc/fstab` si procede y verifica con `chronyc tracking` que el reloj está sincronizado.
      - Windows: tarea programada que copie `C:\Datos` a `D:\Respaldo` cada hora con `copy`. Muestra historial de la tarea.
5. **Backup diario con systemd**
      - Crea `backup-logs.service` y `backup-logs.timer` para añadir los archivos de `/var/log` a `~/copia_de_seguridad/backup.tar.gz` cada día. Incluye ambos archivos, salida de `systemctl list-timers --all` y `systemctl cat backup-logs.service`.
6. **Actualizaciones desatendidas**
      - Configura solo actualizaciones de seguridad en Ubuntu Server con `unattended-upgrades`; muestra fragmento de `/etc/apt/apt.conf.d/50unattended-upgrades` y log de ejecución. En Windows, muestra la política de Windows Update configurada.
7. **Registro de Windows**
      - Cambios: desactivar notificaciones UAC, añadir `notepad.exe` al inicio, mover carpetas especiales a otra partición, deshabilitar USB.
      - Evidencia antes/después desde RegEdit o `reg add/reg query`, más verificación funcional.

## Actividades 3

1. **Conversión de paquetes**
      - Descarga Firefox en formato RPM en Ubuntu Desktop, conviértelo con `alien -d`, instala el `.deb` y comenta por qué convertir. Indica dos métodos alternativos de instalación (snap/apt) y cómo consultar archivos instalados con `dpkg -L`.
2. **Programación de script en cron**
      - Crea un script sencilllo y  con `chmod 777 script.sh` (explica por qué no es buena práctica y qué permiso usarías realmente).
      - Añade en `sudo crontab -e`: `* * * * * ~/Escritorio/script.sh`. Explica qué significa cada asterisco y ajusta para ejecutarse cada minuto  entre las 8 y las 20 todos los días. Confirma con `systemctl list-timers` si optas por un timer equivalente.
      - Verifica funcionamiento y adjunta salida de `grep script.sh /var/log/syslog` o similar.
3. **Laboratorio LXD (multi-perfil, límites y backup)**
      - Inicializa LXD y crea dos perfiles: `default` (red NAT en `lxdbr0`, disco root 10GB) y `lab` (añade un NIC a  una red nueva `redlab` 10.50.0.0/24). Aplica ambos al contenedor `lab01`.
      - En `lab01`: instala `nginx`, fija `limits.memory` a 512MB y `limits.cpu` a 1. Muestra `lxc config show lab01 --expanded` y valida los   límites tras reiniciar.
      - Crea un snapshot `pre-cambio`, modifica la página por defecto de nginx y restaura el snapshot; demuestra que vuelve al estado inicial. Luego exporta el contenedor (`lxc export lab01 lab01.tar.gz`) y documenta el reimportado con otro nombre.
      - Evidencias mínimas: `lxc profile show default/lab`, `lxc network list` y `lxc network show lxdbr0/redlab`, `lxc list` con IPs, `lxc info lab01 --show-log` si hubo errores, capturas de `curl` desde el host antes y después de la restauración.
