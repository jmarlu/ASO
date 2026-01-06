
# Permisos especiales en Linux (SUID, SGID, sticky bit)
- Objetivo: entender que los bits especiales cambian el comportamiento de permisos y ver un ejemplo practico de cada uno.
- Resultado esperado: saber identificar SUID/SGID/sticky en un `ls -l` y explicar su impacto en un entorno multiusuario.

## Requisitos previos (para las pruebas)
- Sistema Linux con permisos de sudo.
- Paquete `acl` instalado (para `getfacl`/`setfacl`).
  - `sudo apt install acl`
- **SUID (setuid, 4xxx)**: un binario se ejecuta con el **UID del dueño**. Ej: `passwd` es SUID de root.
- **SGID (setgid, 2xxx)** en binarios: ejecuta con **GID del dueño**. En directorios: nuevos ficheros heredan el **grupo** del directorio.
- **Sticky bit (1xxx)** en directorios: solo el dueño del fichero (o root) puede borrarlo, aunque otros tengan permisos de escritura. Ej: `/tmp`.

## Pruebas rápidas (Ubuntu)
1. **SUID**:
   ```bash
   # Nota: en algunos sistemas /tmp monta con "nosuid".
   # Si falla, usa /usr/local/bin en lugar de /tmp.
   sudo cp /bin/ping /tmp/ping-suid
   sudo chown root:root /tmp/ping-suid
   sudo chmod 4755 /tmp/ping-suid
   ls -l /tmp/ping-suid    # rwsr-xr-x (s en user)
   /tmp/ping-suid -c1 127.0.0.1   # funciona sin sudo porque eleva a root
   ```
   *Recuerda limpiar*: `sudo rm /tmp/ping-suid`.
2. **SGID en directorio** (herencia de grupo):
   ```bash
   sudo groupadd grupo_datos
   sudo mkdir /tmp/sgid-demo
   sudo chown root:grupo_datos /tmp/sgid-demo
   sudo chmod 2775 /tmp/sgid-demo   # rwsrwsr-x (s en group)
   sudo usermod -aG grupo_datos $(whoami)  # añade tu usuario al grupo
   newgrp grupo_datos                       # activa el grupo en esta shell
   touch /tmp/sgid-demo/archivo
   ls -l /tmp/sgid-demo/archivo     # grupo debe ser 'grupo_datos'
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

# 🗂️ ACL en sistemas de ficheros (GNU/Linux)

> “Compartir sin romper la seguridad: mismo recurso, permisos granulados.”

## 1. Qué son y cuándo usarlas
- **ACL (Access Control Lists)** amplían el modelo `ugo` de UNIX permitiendo permisos por **usuario** y **grupo** adicionales.
- Útiles en **recursos compartidos** (NFS/Samba/Nextcloud): varios equipos/proyectos con permisos diferentes sobre el mismo árbol.
- Indicios: `ls -l` muestra `+` (`drwxrwxr-x+`); `getfacl` lista las entradas.

## 2. Soporte y montaje
- Sistemas de ficheros típicos (`ext4`, `xfs`, `btrfs`) soportan ACL. En `ext4`, la opción `acl` suele venir por defecto.
- Comprueba con:
  ```bash
  findmnt -no SOURCE /     # ver dispositivo real (ej. /dev/sda2)
  mount | grep ext4 | head -n1   # ver opciones (acl)
  tune2fs -l /dev/sdXN | grep features  # debe incluir "acl"
  ```
- Si faltan, monta con `-o acl` o añade `acl` en `/etc/fstab` y remonta (`mount -o remount,acl /punto`).

## 3. Comandos clave
- **Listar**: `getfacl ruta`
- **Añadir/modificar**: `setfacl -m u:usuario:rwx archivo` | `setfacl -m g:grupo:rx dir`
- **Eliminar entrada**: `setfacl -x u:usuario archivo`
- **Reset completo** (a modo unix clásico): `setfacl -b ruta`
- **Default ACL** (para herencia en directorios): `setfacl -m d:u:usuario:rwX compartida/`
- **Recursivo**: `setfacl -R -m g:grupo_datos:rwX compartida/`
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
- Si añades `u:alumno1:rwx` pero la `mask::r-x`, alumno1 solo tendrá `r-x` hasta que subas la máscara.
- Comandos útiles:
  ```bash
  getfacl archivo            # ver mask
  setfacl -m m::rwx archivo  # ajustar máscara
  ```
- Al modificar ACL, la máscara puede bajar automáticamente; revisa tras cambios.

### Permisos efectivos y su impacto en Samba/NFS
- **Permiso efectivo = (ACL) ∩ (mask) ∩ (modo POSIX)**. Si la máscara recorta, el usuario perderá escritura aunque la ACL diga `rwX`.
- **Samba**: el acceso final es la intersección de `valid users`/`read only` del share y los permisos del FS (ACL/posix). Si el FS deniega, Samba deniega.
- **NFS**: el servidor aplica las ACL y el cliente solo ve el resultado. Con `sec=sys`, los UID/GID deben coincidir para que el permiso sea correcto.

### Checkpoint didactico (antes de Samba/NFS)
- Si el alumnado recuerda solo 3 ideas:
  1. `mask` recorta permisos efectivos.
  2. `default ACL` define herencia en directorios.
  3. `setgid` en directorios fuerza el grupo en nuevos ficheros.
- Flujo mental: crear directorio -> permisos POSIX -> setgid -> ACL explicita -> default ACL -> comprobar con `getfacl`.

## 4. Patron tipico en un recurso compartido
1. Crear directorio y propietario base (p. ej. `root:grupo_datos`).
2. Ajustar permisos POSIX a 2770 (setgid para heredar grupo): `chmod 2770 compartida`.
3. Default ACL para que nuevos ficheros hereden:  
   `setfacl -m d:g:grupo_datos:rwX -m d:u:profesor:rwX -m d:u:alumno1:rwX compartida`
4. ACL explicita en el arbol existente:  
   `setfacl -R -m g:grupo_datos:rwX -m u:profesor:rwX -m u:alumno1:rwX compartida`
5. Validar: `getfacl compartida | head`.

### Ejemplo guiado en Ubuntu (prueba rapida)
1. Si no tienes LDAP, prepara usuarios/grupo locales:
   ```bash
   sudo groupadd grupo_datos
   sudo useradd -m -G grupo_datos profesor
   sudo useradd -m -G grupo_datos alumno1
   ```
2. Crea el recurso y aplica permisos base:
   ```bash
   sudo mkdir -p /srv/compartida
   sudo chown root:grupo_datos /srv/compartida
   sudo chmod 2770 /srv/compartida   # setgid para heredar grupo
   ```
3. Añade ACL (explícitas y por defecto):
   ```bash
   sudo setfacl -R -m g:grupo_datos:rwX -m u:profesor:rwX -m u:alumno1:rwX /srv/compartida
   sudo setfacl -R -m d:g:grupo_datos:rwX -m d:u:profesor:rwX -m d:u:alumno1:rwX /srv/compartida
   ```
4. Comprueba la máscara (si ves permisos recortados, ajusta):
   ```bash
   getfacl /srv/compartida
   sudo setfacl -m m::rwx /srv/compartida   # opcional si la mask quedo baja
   ```
5. Valida herencia y acceso:
   ```bash
   sudo -u alumno1 touch /srv/compartida/ok-alumno1   # debe crear
   sudo -u profesor touch /srv/compartida/ok-profesor # debe crear
   ```
6. Revisión final:
   ```bash
   ls -ld /srv/compartida       # debe mostrar g+s y "+"
   getfacl /srv/compartida
   ```
7. Limpieza opcional: `sudo setfacl -bR /srv/compartida` (vuelve al modo POSIX clasico).

## 5. Notas de integración (ACL, Samba y NFS)
- **ACL POSIX**: amplían rwx. La entrada `mask` limita los permisos efectivos de grupo y entradas ACL adicionales; si la `mask` es `r--`, una ACL `rwX` queda en solo lectura.
- **Default ACL**: se heredan en nuevos ficheros/directorios. Sin default ACL, heredan solo el modo POSIX.
- **umask**: afecta a la creación inicial; las default ACL corrigen herencia, pero un `umask 007/027` puede seguir recortando permisos si no hay default ACL.
- **NFS**: el servidor aplica permisos/ACL y el cliente solo ve el resultado. En `sec=sys` todo depende de UID/GID; si no coinciden, fallara el acceso.
- **NFSv4**: puede usar ACL propias. En este laboratorio usamos ACL POSIX en el servidor y exportamos con `acl` para mantener comportamiento uniforme.
- **Samba**: traduce ACL POSIX a ACL estilo Windows. Con `vfs_acl_xattr` y `inherit permissions = yes` se respetan las ACL del FS; valida con `testparm` y una prueba real desde cliente.

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
  /srv/compartida 10.50.0.0/24(rw,sync,subtree_check,acl,root_squash,fsid=0)
  /home/usuarios  10.50.0.0/24(rw,sync,subtree_check,acl,root_squash)
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


## 3. Samba (SMB/CIFS)
### 3.1 Instalacion y configuracion minima
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
  valid users = @grupo_datos

[homes]
  browseable = no
  read only = no
  create mask = 0600
  directory mask = 0700
```
- `acl_xattr` guarda ACL compatibles con clientes Windows; hereda las ACL POSIX si el FS las soporta.
### 3.2 Integracion de permisos
- Usa grupos LDAP para `valid users` y combina con ACL en el FS. La regla es doble: **Samba filtra por grupo** y **el sistema de ficheros aplica permisos/ACL**. Si falla cualquiera, se deniega el acceso.
  - `valid users = @grupo_datos` permite entrar solo a miembros del grupo LDAP.
  - `chmod 2770` asegura setgid (herencia de grupo) y bloquea a “otros”.
  - `setfacl -m d:g:grupo_datos:rwX` asegura que lo nuevo herede escritura para el grupo.
  - `setfacl -m g:grupo_datos:rwX` aplica escritura al directorio existente.
  - La `mask` puede recortar permisos; si ves recorte, sube la mascara con `setfacl -m m::rwx`.
- Cuotas: configúralas en el FS (`setquota`); Samba puede informar de ellas a los clientes.
- Autenticación: `security = user` (local) o `security = ads` si unes a AD. Con LDAP externo, usa backend de cuentas vía `winbind` o `sssd` para resolver UID/GID coherentes.
- Seguridad de transporte: `server signing = mandatory` en redes hostiles; `smb encrypt = required` si quieres cifrado en tránsito (SMB3).
- Resolución de nombres: evita `wins`; usa DNS o IP directa. Prueba con `smbclient -L //filesrv -U usuario`.
- Perfiles/Homes: la sección `[homes]` sirve directorios personales con 0700. Si usas perfiles móviles, ajusta cuotas y paths UNC (`\\filesrv\homes`).

### 3.3 Puesta en marcha y pruebas rapidas
- Instala servidor y cliente: `sudo apt install samba samba-client` (en RHEL/Fedora: `dnf -y install samba samba-client`).
- Servicio: `sudo systemctl enable --now smbd nmbd` (activa NetBIOS para entornos mixtos); revisa sintaxis con `testparm`.
- Usuarios Samba: crea credencial local con `sudo pdbedit -a usuario` (o `smbpasswd -a`); deben existir en el sistema/LDAP.
- Pruebas desde el servidor: `smbclient -L //filesrv -U usuario` para ver compartidos y `smbclient //filesrv/compartida -U usuario` para verificar acceso.
- Para limitar superficie, en `[global]` añade `interfaces = lo eth0` y, si procede, `bind interfaces only = yes`.


## 4. Nextcloud
- Plataforma de ficheros colaborativos (WebDAV) con apps móviles y web.
- Instalación rápida (Ubuntu): `sudo snap install nextcloud` o stack LAMP+PHP-FPM.
- Permisos de ficheros: datos bajo `data/`, dueño `www-data`, `chmod 750`.
- Autenticación LDAP: app "LDAP user and group backend", usa la CA de tu lab TLS.
- Almacenamiento externo: apunta a rutas locales o montadas (NFS/SMB). Las ACL del FS mandan; Nextcloud controla comparticiones lógicas encima.
