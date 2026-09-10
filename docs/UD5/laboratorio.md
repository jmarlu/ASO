# Laboratorio: mantenimiento automático de un servidor

## 1. Entorno y preparación

Usa una **VM Ubuntu Server 24.04 dedicada al aula**, arrancada con systemd, con acceso a repositorios y una cuenta con sudo. Trabaja con datos de prueba. No ejecutes estos cambios en el equipo anfitrión. Antes de empezar, guarda una instantánea de la VM.

Descarga [informe.sh](lab/informe.sh), [copia.sh](lab/copia.sh) y [comprobar-servicio.sh](lab/comprobar-servicio.sh) a una misma carpeta de la VM, por ejemplo `~/ud5-descargas`, y abre una terminal allí. Si usas el repositorio, están en `docs/UD5/lab/`.

```bash
sudo apt update
sudo apt install cron at nginx util-linux
sudo systemctl enable --now cron atd nginx
sudo useradd --system --user-group --create-home --home-dir /var/lib/aso-ud5 --shell /usr/sbin/nologin asoauto
sudo usermod -aG systemd-journal asoauto
sudo install -d -o root -g root -m 755 /usr/local/lib/aso-ud5
sudo install -o root -g root -m 755 informe.sh copia.sh comprobar-servicio.sh /usr/local/lib/aso-ud5/
sudo install -d -o asoauto -g asoauto -m 700 /var/lib/aso-ud5/{informes,copias,estado,restauracion}
sudo install -d -o root -g asoauto -m 750 /srv/aso-ud5/datos
printf 'Documento de prueba UD5\n' | sudo tee /srv/aso-ud5/datos/ejemplo.txt
sudo chmod 644 /srv/aso-ud5/datos/ejemplo.txt
id asoauto
timedatectl
```

`useradd` se ejecuta una vez en una VM limpia. Si ya existe la cuenta, comprueba su configuración con `getent passwd asoauto` e `id asoauto` antes de continuar. No añadas usuarios con sudo a la cuenta automática. La pertenencia a `systemd-journal` permite que el informe vea los registros del sistema.

## 2. Probar antes de programar

Lee los scripts descargados. Localiza validación, bloqueo, códigos de salida y tratamiento de archivos temporales.

```bash
bash -n /usr/local/lib/aso-ud5/informe.sh
bash -n /usr/local/lib/aso-ud5/copia.sh
bash -n /usr/local/lib/aso-ud5/comprobar-servicio.sh
sudo -u asoauto /usr/local/lib/aso-ud5/informe.sh /var/lib/aso-ud5/informes
sudo -u asoauto cat /var/lib/aso-ud5/informes/ultimo.txt
sudo -u asoauto /usr/local/lib/aso-ud5/copia.sh /srv/aso-ud5/datos /var/lib/aso-ud5/copias
sudo -u asoauto /usr/local/lib/aso-ud5/comprobar-servicio.sh nginx.service /var/lib/aso-ud5/estado
```

Esperado: informe con fecha actual, archivo `copia-....tar.gz` y mensaje `OK nginx.service`. Una cuenta con shell `nologin` puede ejecutar estas órdenes mediante `sudo -u`; no necesita abrir una sesión interactiva.

## 3. Primera programación con cron

Crea `/etc/cron.d/aso-ud5` con `sudoedit /etc/cron.d/aso-ud5`:

```text
SHELL=/bin/sh
PATH=/usr/sbin:/usr/bin:/sbin:/bin
* * * * * asoauto /usr/local/lib/aso-ud5/informe.sh /var/lib/aso-ud5/informes >> /var/lib/aso-ud5/informes/cron.log 2>&1
```

Guarda una nueva línea al final y fija los permisos:

```bash
sudo chown root:root /etc/cron.d/aso-ud5
sudo chmod 644 /etc/cron.d/aso-ud5
sudo systemctl status cron --no-pager
```

Espera al siguiente minuto. Comprueba la nueva fecha de `ultimo.txt`, el propietario y el registro:

```bash
sudo -u asoauto cat /var/lib/aso-ud5/informes/cron.log
sudo -u asoauto stat /var/lib/aso-ud5/informes/ultimo.txt
sudo journalctl -u cron --since '-5 minutes' --no-pager
```

Cambia después `* * * * *` por `0 8 * * *` y explica el calendario. Antes de pasar a systemd, retira **solo** este archivo del laboratorio para evitar dos planificadores sobre la misma tarea:

```bash
sudo rm /etc/cron.d/aso-ud5
```

## 4. Tarea puntual con at

```bash
printf '%s\n' '/usr/local/lib/aso-ud5/informe.sh /var/lib/aso-ud5/informes >> /var/lib/aso-ud5/informes/at.log 2>&1' | sudo -u asoauto at now + 2 minutes
sudo -u asoauto atq
```

Anota el identificador y usa `sudo -u asoauto at -c ID`, sustituyendo ID por el número real. Tras ejecutarse, la tarea desaparecerá de `atq`; comprueba `at.log` y la fecha del informe. Programa otra tarea y cancélala con `sudo -u asoauto atrm ID`. No canceles trabajos ajenos.

## 5. Informe diario con systemd

Crea `/etc/systemd/system/aso-informe.service`:

```ini
[Unit]
Description=Informe de mantenimiento ASO

[Service]
Type=oneshot
User=asoauto
Group=asoauto
UMask=0077
ExecStart=/usr/local/lib/aso-ud5/informe.sh /var/lib/aso-ud5/informes
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/aso-ud5
```

Crea `/etc/systemd/system/aso-informe.timer`:

```ini
[Unit]
Description=Informe diario ASO

[Timer]
OnCalendar=*-*-* 08:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
sudo systemd-analyze verify /etc/systemd/system/aso-informe.service /etc/systemd/system/aso-informe.timer
systemd-analyze calendar '*-*-* 08:00:00'
sudo systemctl daemon-reload
sudo systemctl start aso-informe.service
systemctl show aso-informe.service -p Result -p ExecMainStatus
sudo systemctl enable --now aso-informe.timer
systemctl list-timers --all aso-informe.timer
sudo journalctl -u aso-informe.service -n 20 --no-pager
```

Esperado: `Result=success`, `ExecMainStatus=0`, archivo actualizado y próximo disparo. El servicio no tiene por qué permanecer activo tras terminar.

Para comprobar la persistencia sin cambiar el reloj de la VM:

1. Cambia temporalmente `OnCalendar` a `*-*-* *:*:00` y añade `AccuracySec=1s` dentro de `[Timer]`.
2. Ejecuta `daemon-reload` y `restart aso-informe.timer`; deja que se produzca una ejecución automática.
3. Detén **solo el timer** con `sudo systemctl stop aso-informe.timer` y espera a que pase al menos un minuto completo.
4. Arráncalo y comprueba en el journal que recupera una ejecución pendiente. Esta prueba simula la inactividad del timer; como ampliación, repítela con un apagado de la VM.
5. Restablece las 08:00, retira `AccuracySec=1s`, recarga y reinicia el timer. Conserva evidencias de ambos calendarios.

## 6. Copia y comprobación de servicio

Usa el mismo esquema de servicio para crear `aso-copia.service` y `aso-comprobar.service`: conserva las directivas de `[Service]`, cambia `Description` y sustituye `ExecStart` por la orden correspondiente:

```ini
# En aso-copia.service
ExecStart=/usr/local/lib/aso-ud5/copia.sh /srv/aso-ud5/datos /var/lib/aso-ud5/copias
```

```ini
# En aso-comprobar.service
ExecStart=/usr/local/lib/aso-ud5/comprobar-servicio.sh nginx.service /var/lib/aso-ud5/estado
```

Cada servicio lleva **una sola** línea `ExecStart`. Crea `aso-copia.timer` como el timer del informe, con descripción de copia, calendario `*-*-* 02:30:00` y `Persistent=true`.

Crea `aso-comprobar.timer`:

```ini
[Unit]
Description=Comprobacion periodica de nginx

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

```bash
sudo systemd-analyze verify /etc/systemd/system/aso-copia.service /etc/systemd/system/aso-copia.timer /etc/systemd/system/aso-comprobar.service /etc/systemd/system/aso-comprobar.timer
sudo systemctl daemon-reload
sudo systemctl start aso-copia.service aso-comprobar.service
sudo systemctl enable --now aso-copia.timer aso-comprobar.timer
systemctl list-timers --all 'aso-*.timer'
```

También puedes contrastar tus archivos con las plantillas completas:

| Tarea | Servicio | Temporizador |
|---|---|---|
| Informe | [aso-informe.service](lab/aso-informe.service) | [aso-informe.timer](lab/aso-informe.timer) |
| Copia | [aso-copia.service](lab/aso-copia.service) | [aso-copia.timer](lab/aso-copia.timer) |
| Comprobación | [aso-comprobar.service](lab/aso-comprobar.service) | [aso-comprobar.timer](lab/aso-comprobar.timer) |

## 7. Restaurar una copia

Lista las copias y copia el nombre real de una de ellas en la variable `archivo_copia`:

```bash
sudo -u asoauto ls /var/lib/aso-ud5/copias
archivo_copia=/var/lib/aso-ud5/copias/copia-SUSTITUIR_POR_NOMBRE_REAL.tar.gz
sudo -u asoauto tar -tzf "$archivo_copia"
sudo -u asoauto tar -xzf "$archivo_copia" -C /var/lib/aso-ud5/restauracion
sudo -u asoauto cmp /srv/aso-ud5/datos/ejemplo.txt /var/lib/aso-ud5/restauracion/ejemplo.txt
```

`cmp` no muestra salida y devuelve 0 si coinciden. Extrae únicamente las copias creadas en este laboratorio y en el directorio de restauración separado. Ejecuta seis copias, comprueba que quedan cinco y que un archivo ajeno al patrón de copias no se elimina.

## 8. Provocar y resolver fallos

### Destino sin permiso de escritura

```bash
sudo chmod 500 /var/lib/aso-ud5/copias
sudo systemctl start aso-copia.service
systemctl show aso-copia.service -p Result -p ExecMainStatus
sudo journalctl -u aso-copia.service -n 15 --no-pager
sudo chmod 700 /var/lib/aso-ud5/copias
sudo systemctl start aso-copia.service
systemctl show aso-copia.service -p Result -p ExecMainStatus
```

La primera ejecución debe fallar y la segunda funcionar. No uses `chmod 777` para resolverlo.

### Servicio detenido

```bash
sudo systemctl stop nginx
sudo systemctl start aso-comprobar.service
sudo -u asoauto cat /var/lib/aso-ud5/estado/nginx.service.incidencia
sudo systemctl start nginx
sudo systemctl start aso-comprobar.service
sudo -u asoauto ls -la /var/lib/aso-ud5/estado
```

Esperado: código 1 e incidencia con nginx detenido; código 0 y retirada de la incidencia tras arrancarlo. La comprobación detecta el problema, no reinicia automáticamente nginx.

### Ejecución simultánea

En una terminal, mantén el bloqueo:

```bash
sudo -u asoauto flock /var/lib/aso-ud5/copias/.copia.lock sleep 60
```

Mientras tanto, ejecuta la copia en otra terminal y consulta inmediatamente `echo $?`. Debe devolver 75. Una vez liberado el bloqueo, repite y comprueba éxito.

## 9. Retirada del laboratorio

Primero exporta tus evidencias. Deshabilita los tres timers con `sudo systemctl disable --now aso-informe.timer aso-copia.timer aso-comprobar.timer`; comprueba que no están activos los servicios antes de retirar sus seis archivos concretos de `/etc/systemd/system/`. Ejecuta `sudo systemctl daemon-reload`.

Consulta `sudo -u asoauto atq` y cancela solo los trabajos pendientes de esta práctica. Si conservaste la configuración cron, retira únicamente `/etc/cron.d/aso-ud5`. Conserva datos y cuenta hasta terminar la evaluación; la forma más sencilla de recuperar el entorno inicial es restaurar la instantánea de esta VM dedicada.

Continúa con las [actividades de KCron, cuentas y caso final](actividades.md).
