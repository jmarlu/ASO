# 🗂️ ACL en sistemas de ficheros (GNU/Linux)

> “Compartir sin romper la seguridad: mismo recurso, permisos granulados.”

## Permisos especiales en Linux (SUID, SGID, sticky bit)
- **SUID (setuid, 4xxx)**: un binario se ejecuta con el **UID del dueño**. Ej: `passwd` es SUID de root.
- **SGID (setgid, 2xxx)** en binarios: ejecuta con **GID del dueño**. En directorios: nuevos ficheros heredan el **grupo** del directorio.
- **Sticky bit (1xxx)** en directorios: solo el dueño del fichero (o root) puede borrarlo, aunque otros tengan permisos de escritura. Ej: `/tmp`.

### Pruebas rápidas (Ubuntu)
1. **SUID**:
   ```bash
   sudo cp /bin/ping /tmp/ping-suid
   sudo chown root:root /tmp/ping-suid
   sudo chmod 4755 /tmp/ping-suid
   ls -l /tmp/ping-suid    # rwsr-xr-x (s en user)
   /tmp/ping-suid -c1 127.0.0.1   # funciona sin sudo porque eleva a root
   ```
   *Recuerda limpiar*: `sudo rm /tmp/ping-suid`.
2. **SGID en directorio** (herencia de grupo):
   ```bash
   sudo groupadd compartida
   sudo mkdir /tmp/sgid-demo
   sudo chown root:compartida /tmp/sgid-demo
   sudo chmod 2775 /tmp/sgid-demo   # rwsrwsr-x (s en group)
   sudo usermod -aG compartida $(whoami)   # añade tu usuario al grupo
   newgrp compartida                       # activa el grupo en esta shell
   touch /tmp/sgid-demo/archivo
   ls -l /tmp/sgid-demo/archivo     # grupo debe ser 'compartida'
   ```
3. **Sticky bit**:
   ```bash
   sudo mkdir /tmp/sticky-demo
   sudo chmod 1777 /tmp/sticky-demo   # rwxrwxrwt (t)
   sudo touch /tmp/sticky-demo/f1
   sudo -u nobody touch /tmp/sticky-demo/f2
   sudo -u nobody rm /tmp/sticky-demo/f1   # debe FALLAR (no es dueño)
   sudo -u nobody rm /tmp/sticky-demo/f2   # debe funcionar (es dueño)
   ```
   *Limpieza*: `sudo rm -r /tmp/sgid-demo /tmp/sticky-demo`.

## 1. Qué son y cuándo usarlas
- **ACL (Access Control Lists)** amplían el modelo `ugo` de UNIX permitiendo permisos por **usuario** y **grupo** adicionales.
- Útiles en **recursos compartidos** (NFS/Samba/Nextcloud): varios equipos/proyectos con permisos diferentes sobre el mismo árbol.
- Indicios: `ls -l` muestra `+` (`drwxrwxr-x+`); `getfacl` lista las entradas.

## 2. Soporte y montaje
- Sistemas de ficheros típicos (`ext4`, `xfs`, `btrfs`) soportan ACL. En `ext4`, la opción `acl` suele venir por defecto.
- Comprueba con:
  ```bash
  mount | grep ext4 | head -n1   # ver opciones (acl)
  tune2fs -l /dev/sdXN | grep features  # debe incluir "acl"
  ```
- Si faltan, monta con `-o acl` o añade `acl` en `/etc/fstab` y remonta (`mount -o remount,acl /punto`).

## 3. Comandos clave
- **Listar**: `getfacl ruta`
- **Añadir/modificar**: `setfacl -m u:usuario:rwx archivo` | `setfacl -m g:grupo:rx dir`
- **Eliminar entrada**: `setfacl -x u:usuario archivo`
- **Reset completo** (a modo unix clásico): `setfacl -b ruta`
- **Default ACL** (para herencia en directorios): `setfacl -m d:u:usuario:rwX proyecto/`
- **Recursivo**: `setfacl -R -m g:equipo:rwX proyecto/`
- **Máscara**: `mask` limita permisos efectivos. Tras añadir muchas entradas, usa `setfacl -m m::rwx dir` si quieres que se apliquen completas.

### Parámetros frecuentes de `setfacl`
- `-m` / `--modify`: añade o cambia entradas. Sintaxis `tipo:identidad:permisos` donde `tipo` es `u` (usuario), `g` (grupo), `m` (mask), `o` (otros) o `d:` para default.
- `-x` / `--remove`: elimina entradas concretas (`setfacl -x u:ana archivo`).
- `-b` / `--remove-all`: borra todas las ACL de la ruta.
- `-R` / `--recursive`: aplica en todo el árbol descendente.
- `-d`: prefijo para default ACL en directorios (`d:u:luis:rwX`).
- `-k`: elimina las default ACL.
- `-n` / `--no-mask`: no recalcula la máscara (cuidado, puede dejar ACL inefectivas si la máscara queda baja).
- `--set`: reemplaza todas las entradas con una lista nueva (útil para definir de cero).
- Permisos: `r` lectura, `w` escritura, `x` ejecución; `X` aplica `x` solo si es directorio o ya tenía `x`.

### La máscara en ACL POSIX
- Define el **máximo** de permisos efectivos para todas las entradas **que no sean el dueño** (grupos y usuarios adicionales).
- Si añades `u:luis:rwx` pero la `mask::r-x`, Luis solo tendrá `r-x` hasta que subas la máscara.
- Comandos útiles:
  ```bash
  getfacl archivo            # ver mask
  setfacl -m m::rwx archivo  # ajustar máscara
  ```
- Al modificar ACL, la máscara puede bajar automáticamente; revisa tras cambios.

## 4. Patrón típico en un recurso compartido
1. Crear directorio y dueño base (p. ej. `root:proyecto`).
2. Ajustar permisos POSIX a 2770 (setgid para heredar grupo): `chmod 2770 proyecto`.
3. Default ACL para que nuevos ficheros hereden:  
   `setfacl -m d:g:equipo:rwX -m d:u:luis:rwX -m d:u:ana:rX proyecto`
4. ACL explícita en el árbol existente:  
   `setfacl -R -m g:equipo:rwX -m u:luis:rwX -m u:ana:rX proyecto`
5. Validar: `getfacl proyecto | head`.

### Ejemplo guiado en Ubuntu (prueba rápida)
1. Prepara usuarios/grupo:
   ```bash
   sudo groupadd equipo
   sudo useradd -m -G equipo luis
   sudo useradd -m ana
   ```
2. Crea el recurso y aplica permisos base:
   ```bash
   sudo mkdir -p /srv/proyecto
   sudo chown root:equipo /srv/proyecto
   sudo chmod 2770 /srv/proyecto   # setgid para heredar grupo equipo
   ```
3. Añade ACL (explícitas y por defecto):
   ```bash
   sudo setfacl -R -m g:equipo:rwX -m u:luis:rwX -m u:ana:rX /srv/proyecto
   sudo setfacl -R -m d:g:equipo:rwX -m d:u:luis:rwX -m d:u:ana:rX /srv/proyecto
   ```
4. Comprueba la máscara (si ves permisos recortados, ajusta):
   ```bash
   getfacl /srv/proyecto
   sudo setfacl -m m::rwx /srv/proyecto   # opcional si la mask quedó baja
   ```
5. Valida herencia y acceso:
   ```bash
   sudo -u luis touch /srv/proyecto/ok-luis   # debe crear
   sudo -u ana  touch /srv/proyecto/ok-ana    # debe fallar en escritura (solo rX)
   sudo -u ana  ls /srv/proyecto              # puede leer/listar
   ```
6. Revisión final:
   ```bash
   ls -ld /srv/proyecto       # debe mostrar g+s y "+"
   getfacl /srv/proyecto
   ```
7. Limpieza opcional: `sudo setfacl -bR /srv/proyecto` (vuelve al modo POSIX clásico).

## 5. Notas de integración
- **NFSv4**: usa su propio modelo de ACL; si exportas NFS clásico, exporta con `--manage-gids` y conserva ACL POSIX en el servidor.
- **Samba**: respeta ACL POSIX; si usas `vfs_acl_xattr`, documenta la diferencia. Tras aplicar ACL, haz `testparm` y prueba desde un cliente.
- **umask**: afecta creación inicial; las default ACL corrigen herencia, pero conviene un `umask 002` en servicios compartidos.

---

# 🌐 Recursos compartidos en entornos heterogéneos

> "Un único directorio de identidades (LDAP), varios protocolos de acceso a ficheros."

## 1. Escenarios heterogéneos y protocolos
- Mixtos Linux/Windows/web. Objetivos: identidad centralizada, transporte eficiente y permisos coherentes.
- Protocolos habituales:
  - **NFS** (Unix-like): trabaja con UID/GID, ligero y rápido entre sistemas POSIX.
  - **SMB/CIFS (Samba)**: preferido en Windows, soportado en Linux/macOS; ACL estilo NTFS y funciones de dominio/compartidos.
  - **WebDAV/Nextcloud**: acceso por navegador/app, versiones y compartición fina; se apoya en almacenamiento local o remoto.
- **LDAP** proporciona usuarios y grupos; los servicios de ficheros mapean esas identidades para aplicar permisos.

## 2. NFS
### 2.1 Instalación básica
```bash
sudo apt install nfs-kernel-server   # servidor
sudo apt install nfs-common          # cliente
```
### 2.2 Exportación y opciones clave
- El FS debe soportar ACL POSIX si quieres herencia/permisos granulares.
- `/etc/exports` ejemplo:
  ```
  /srv/compartida 10.0.0.0/24(rw,sync,subtree_check,acl,root_squash,fsid=0)
  /home/usuarios  10.0.0.0/24(rw,sync,subtree_check,acl,root_squash)
  ```
  - `root_squash`: root del cliente no es root en servidor.
  - `acl`: exporta respetando ACL POSIX.
  - `fsid=0`: pseudo-root para NFSv4.
### 2.3 Cliente y montaje automático
- Manual: `mount -t nfs filesrv:/srv/compartida /mnt/comp`.
- `/etc/fstab`: `filesrv:/srv/compartida /mnt/comp nfs defaults,_netdev 0 0`.
- `autofs`: `/etc/auto.master` + `/etc/auto.nfs` para montar bajo demanda.
### 2.4 Consideraciones
- NFSv3: UID/GID sin firma; NFSv4 añade `idmapd` (mapa de nombres) y soporta Kerberos (`sec=krb5`, `krb5i`, `krb5p`).
- Sincroniza hora (NTP), comprueba `idmapd.conf` (dominio igual en cliente/servidor).
- Firewall: abre `2049/tcp/udp` (NFS) y puertos rpcbind (`111`). En NFSv4 puro puedes limitar a 2049.
- Rendimiento: usa `async` solo si aceptas riesgo; `rsize/wsize` altos (64K) en clientes modernos; red rápida.
- Integración LDAP: el servidor debe ver los mismos UID/GID (nsswitch/sssd). El cliente solo necesita la resolución de nombres si monta con `sec=sys`; con Kerberos, ticket válido.

## 3. Nextcloud
- Plataforma de ficheros colaborativos (WebDAV) con apps móviles y web.
- Instalación rápida (Ubuntu): `sudo snap install nextcloud` o stack LAMP+PHP-FPM.
- Permisos de ficheros: datos bajo `data/`, dueño `www-data`, `chmod 750`.
- Autenticación LDAP: app "LDAP user and group backend", usa la CA de tu lab TLS.
- Almacenamiento externo: apunta a rutas locales o montadas (NFS/SMB). Las ACL del FS mandan; Nextcloud controla comparticiones lógicas encima.

## 4. Samba (SMB/CIFS)
### 4.1 Instalación y configuración mínima
```bash
sudo apt install samba
```
`/etc/samba/smb.conf` ejemplo:
```ini
[global]
  workgroup = WORKGROUP
  security = user
  map to guest = never
  vfs objects = acl_xattr
  inherit permissions = yes

[compartida]
  path = /srv/compartida
  read only = no
  create mask = 0660
  directory mask = 2770
  valid users = @equipo

[homes]
  browseable = no
  read only = no
  create mask = 0600
  directory mask = 0700
```
- `acl_xattr` guarda ACL compatibles con clientes Windows; hereda las ACL POSIX si el FS las soporta.
### 4.2 Integración de permisos
- Usa grupos LDAP para `valid users` y combina con ACL en el FS (`chmod 2770`, `setfacl -m d:g:equipo:rwX /srv/compartida`).
- Cuotas: configúralas en el FS (`setquota`); Samba puede informar de ellas a los clientes.
- Autenticación: `security = user` (local) o `security = ads` si unes a AD. Con LDAP externo, usa backend de cuentas vía `winbind` o `sssd` para resolver UID/GID coherentes.
- Seguridad de transporte: `server signing = mandatory` en redes hostiles; `smb encrypt = required` si quieres cifrado en tránsito (SMB3).
- Resolución de nombres: evita `wins`; usa DNS o IP directa. Prueba con `smbclient -L //filesrv -U usuario`.
- Perfiles/Homes: la sección `[homes]` sirve directorios personales con 0700. Si usas perfiles móviles, ajusta cuotas y paths UNC (`\\filesrv\homes`).

## 5. Integración en el laboratorio
- LDAP en Docker (con TLS) sigue siendo la fuente de identidad.
- Fileserver en LXD: `sssd` + `pam_mkhomedir` para resolver LDAP y crear homes (`/home/usuarios/%u` con 0700).
- Recursos:
  - Compartida: `/srv/compartida`, `root:equipo`, `chmod 2770`, default ACL para el grupo.
  - Exportar por NFS o Samba según el cliente; Nextcloud opcional como puerta web.
- Validación típica: `getent passwd alumno`, `su - alumno` crea home; `touch /srv/compartida/ok` solo si pertenece a `equipo`; acceso NFS/SMB respeta esas ACL; si Nextcloud apunta al mismo FS, los cambios se ven en todos lados.
