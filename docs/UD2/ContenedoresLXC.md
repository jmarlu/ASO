# Contenedores LXD (sobre LXC)

Objetivo: que el alumnado entienda qué son los contenedores ligeros en Linux, cómo se diferencian de las máquinas virtuales y cómo gestionar todo su ciclo de vida con LXD (crear, red, perfiles, límites, snapshots, backup, servicios dentro). LXD usa LXC por debajo, pero aporta una CLI y API más sencilla.

## 0. Conceptos clave

- LXD es una capa de gestión para contenedores LXC: proporciona CLI (`lxc`), API REST, redes y storage listos para usar sin editar configs a mano.
- Aislamiento: namespaces + cgroups; kernel compartido con el host, pero con procesos, red y FS propios por contenedor.
- Ventajas frente a VM: arranque muy rápido, bajo consumo. Limitación: mismo kernel/arquitectura que el host.

<!-- Para explicarlo en clase: son cajas en el mismo suelo (kernel) con paredes (namespaces) y normas de aforo (cgroups). LXD es el ayudante que crea y organiza las cajas con un solo comando. -->

## 1. Instalación y primer contenedor (LXD)

En Ubuntu es preferible usar el snap oficial (te mantiene en la rama `5.21/stable` del proyecto):

```bash
sudo snap install lxd
sudo lxd --version            # debe mostrar 5.21.x si sigues la rama estable actual
sudo snap refresh lxd --channel=5.21/stable
```

En Debian o distros sin snap, usa el paquete `lxd` del repositorio (o el tarball publicado por Canonical si no hay paquete).

Inicializa LXD (configura bridge y storage; acepta valores por defecto salvo que tengas requisitos). Las dos preguntas críticas:
- Storage pool: si no tienes disco para ZFS/LVM, elige `dir` para empezar; en producción mejor ZFS o LVM thin.
- Red: crea un bridge gestionado (`lxdbr0`) salvo que quieras unirlo a un bridge existente del host.

```bash
sudo lxd init
```

Lanza un contenedor Ubuntu 22.04:

```bash
lxc launch images:ubuntu/22.04 web01
```

Verificaciones guiadas (alumno):
- `lxc list` (debe mostrar RUNNING y la IP).
- Dentro: `lxc exec web01 -- hostname`, `lxc exec web01 -- ip a`, `lxc exec web01 -- ps -ef | head`.
- Detener/arrancar: `lxc stop web01`, `lxc start web01`.

## 2. Imágenes y perfiles básicos

- Lista remotas y catálogos disponibles: `lxc remote list`, `lxc image list images: | head`.
- Ver qué aplica el perfil por defecto: `lxc profile show default` (incluye la interfaz en `lxdbr0` y el disco root).
- Ajustar tamaño del disco root del perfil por defecto (útil para ejercicios): `lxc profile set default root.size 10GB`.
- Crear contenedores con otro perfil: `lxc launch images:ubuntu/22.04 test --profile default --profile lab`.
- Inspección de configuración final de un contenedor: `lxc config show web01 --expanded`.

## 3. Red básica (bridge por defecto)

- LXD crea `lxdbr0` (NAT) en el init; comprueba con `ip a` en el host.
- Dentro del contenedor, la interfaz suele ser `eth0` con IP privada (default 10.XXX).
- Prueba de conectividad:
  - Desde host: `ping -c2 <IP_contenedor>`.
  - Desde contenedor: `lxc exec web01 -- ping -c2 8.8.8.8` y `lxc exec web01 -- ping -c2 <IP_host>`.
  - Ver redes gestionadas por LXD: `lxc network list` y detalles con `lxc network show lxdbr0`.

## 4. Servicios dentro del contenedor

Ejemplo: instalar y gestionar nginx .

```bash
lxc start web01
lxc exec web01 -- apt update
lxc exec web01 -- apt install -y nginx
lxc exec web01 -- systemctl status nginx
```

Confirmar desde el host:

```bash
curl http://<IP_contenedor>    # debe devolver la página por defecto
```

Para impedir arranque automático dentro del contenedor:

```bash
lxc exec web01 -- systemctl disable nginx
```

En caso de no querer usar `systemd` dentro (contenedor mínimo), ejecuta procesos con `lxc exec web01 -- bash` y lanza servicios en foreground para pruebas rápidas.

## 5. Autostart del contenedor

Habilitar que el contenedor arranque con el host:

```bash
lxc config set web01 boot.autostart true
lxc config set web01 boot.autostart-delay 5   # opcional
```

Verificar:

```bash
lxc list   # columna AUTOSTART debe mostrar YES si se incluye con --columns=ns4t
```

## 6. Límites de recursos (cgroups)

Ejemplos con LXD:

```bash
lxc config set web01 limits.memory 512MB
lxc config set web01 limits.cpu 1
lxc config set web01 limits.processes 512
```

Aplica y valida:

```bash
lxc restart web01
lxc config get web01 limits.memory
```

## 7. Snapshots y backups

- Snapshot (copy-on-write):

```bash
lxc snapshot web01 snap0
lxc info web01   # ver snapshots
```

- Restaurar snapshot:

```bash
lxc restore web01 snap0
```

- Exportar/importar (backup):

```bash
lxc export web01 web01-backup.tar.gz
lxc import web01-backup.tar.gz
```

- Copiar/mover entre hosts LXD: añadir un remoto (`lxc remote add backup <IP>`) y `lxc copy web01 backup:web01` (usa certificados).

## 8. Seguridad y buenas prácticas

- LXD usa contenedores no privilegiados por defecto; mantén esa configuración.
- Usa perfiles para bind mounts y redes:

```bash
lxc config device add web01 datos disk source=/srv/datos path=/srv/datos
```

- Si necesitas red diferente, crea un perfil:

```bash
lxc network create redlab ipv4.address=10.50.0.1/24 ipv4.nat=true
lxc profile create lab
lxc profile device add lab eth0 nic network=redlab name=eth0
lxc profile apply web01 default,lab
```

- Minimiza superficie: instala solo lo necesario en el contenedor y no mezcles servicios sin relación.
- Para depurar, mira logs con `lxc monitor --type=logging` y `lxc info web01 --show-log`.

## 9. Limpieza

```bash
lxc stop web01
lxc delete web01
lxc list   # comprobar que ya no está
```

<!-- ## Para el profesor (hilo didáctico)

- Empieza con la metáfora “cajas en el mismo suelo” para diferenciar kernel compartido vs VM.
- Demuestra creación/arranque en vivo y enseña `lxc list` para que vean estados e IP.
- Pide a los alumnos comprobar IP y hacer `curl` desde el host tras instalar nginx: refuerza red y servicio.
- Cierra enseñando un límite de CPU/memoria y un snapshot; recalca cuándo preferir contenedor vs VM.
-->
