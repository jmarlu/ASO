---
search:
  exclude: true
---

# Guion de clase UD4 - Permisos especiales, ACL y recursos compartidos

## Objetivo de la sesion
- Comprender SUID, SGID y sticky bit con ejemplos reales.
- Manejar ACL POSIX y explicar la mascara y la herencia.
- Conectar ACL con NFS/Samba a nivel conceptual y practico.

## Alcance del guion (importante)
- Este guion esta pensado para **clase guiada en contenedores LXD** (entorno rapido de aula).
- La **practica evaluable UD4** es el laboratorio integrado de `docs/UD4/actividades.md` (flujo VM-SERVIDOR/VM-CLIENTE con LDAP/SSSD).
- Equivalencia didactica:
  - Guion de clase: valida conceptos y comandos base.
  - Actividades UD4: valida integracion completa del escenario del curso.
- Mapa rapido de nombres (coherencia con `docs/UD4/actividades.md`):
  - En este guion: `ud4-lab:/srv/aso-ud4/compartida` (share `compartida`).
  - En actividades: `10.50.0.11:/srv/grupo_clase` (share `grupo_clase`).
  - Es el mismo patron tecnico (ACL + Samba/NFS); solo cambian nombres/rutas del entorno.

## Requisitos previos (5 min)
- Sistema Linux con sudo.
- LXD instalado e inicializado (laboratorio en contenedor).
  - Instalar: `sudo apt install lxd`
  - Inicializar: `sudo lxd init`
- Los servicios (ACL, Samba, NFS) se ejecutan dentro del contenedor.

## Material preparado en este repo
- Script de laboratorio: `docs/UD4/lab/ud4_lab.sh`.
- Teoria actualizada: `docs/UD4/teoria.md`.

## Estructura y tiempos sugeridos (50-60 min)
1. Introduccion y objetivos (5 min)
2. SUID/SGID/Sticky con demo rapida (15 min)
3. ACL POSIX y mascara (15 min)
4. Puente a Samba/NFS (10 min)
5. Mini resumen y preguntas (5 min)

## Demo en directo (paso a paso)
### Modalidad recomendada de clase (guiada)
- Dinamica fija por bloque:
  1. Tu explicas la idea (30-60 s).
  2. Alumnos ejecutan 1-3 comandos.
  3. Parada de verificacion comun (salida esperada).
- Regla practica: no avanzar al siguiente bloque hasta que al menos 2 equipos confirmen la salida.
- Si hay retraso, usa el atajo `./docs/UD4/lab/ud4_lab.sh demo-acl` solo como plan B.

### 0) Preparar contenedores del laboratorio
Tu explicas:
- "Primero preparamos servidor y cliente. Esto se hace una sola vez al inicio."

Alumnos ejecutan:
```bash
./docs/UD4/lab/ud4_lab.sh setup
./docs/UD4/lab/ud4_lab.sh setup-client
```
Parada de verificacion (salida esperada):
```text
Servidor preparado en 'ud4-lab' con recursos en /srv/aso-ud4
Cliente preparado en 'ud4-client'
```
Si quieres entrar en modo interactivo:
```bash
./docs/UD4/lab/ud4_lab.sh shell
./docs/UD4/lab/ud4_lab.sh shell-client
```
Desde aqui, ejecuta los comandos del guion **directamente en shell**:
- Bloques de servidor: en la shell de `ud4-lab`.
- Bloques de cliente: en la shell de `ud4-client`.

### 1) SUID, SGID, sticky bit
**Idea clave**: los bits especiales cambian el comportamiento del sistema de permisos.

1. SUID
Tu explicas:
- "SUID en binarios: el proceso corre con el UID del propietario del binario."

Alumnos ejecutan:
```bash
# Demo robusta: compilamos un binario minimo para ver ruid/euid.
apt-get update -y
apt-get install -y gcc
bash -c "cat >/tmp/ruid.c <<'EOF'
#include <stdio.h>
#include <unistd.h>
int main(void){ printf(\"ruid=%d euid=%d\\n\", getuid(), geteuid()); return 0; }
EOF"
gcc /tmp/ruid.c -o /tmp/ruid
sudo -u alumno1 /tmp/ruid     # ruid=UID_alumno1 euid=UID_alumno1
chown root:root /tmp/ruid
chmod 4755 /tmp/ruid
ls -l /tmp/ruid
sudo -u alumno1 /tmp/ruid     # ruid=UID_alumno1 euid=0
rm -f /tmp/ruid /tmp/ruid.c
```
Parada de verificacion (salida esperada):
```text
-rwsr-xr-x 1 root root ... /tmp/ruid
ruid=<UID de alumno1> euid=<UID de alumno1>
ruid=<UID de alumno1> euid=0
```
Explica que el binario se ejecuta como root y por eso funciona sin sudo.

2. SGID en directorio
Tu explicas:
- "SGID en directorios fuerza herencia de grupo en ficheros nuevos."

Alumnos ejecutan:
```bash
groupadd -f grupo_datos
mkdir -p /tmp/sgid-demo
chown root:grupo_datos /tmp/sgid-demo
chmod 2775 /tmp/sgid-demo
usermod -aG grupo_datos alumno1
sudo -u alumno1 touch /tmp/sgid-demo/archivo
ls -l /tmp/sgid-demo/archivo
```
Parada de verificacion (salida esperada):
```text
-rw-r--r-- 1 alumno1 grupo_datos ... /tmp/sgid-demo/archivo
```
Explica la herencia de grupo.

3. Sticky bit
Tu explicas:
- "En directorios con sticky, solo el dueño (o root) puede borrar su fichero."

Alumnos ejecutan:
```bash
mkdir -p /tmp/sticky-demo
chmod 1777 /tmp/sticky-demo
touch /tmp/sticky-demo/f1
sudo -u nobody touch /tmp/sticky-demo/f2
sudo -u nobody rm /tmp/sticky-demo/f1
sudo -u nobody rm /tmp/sticky-demo/f2
rm -r /tmp/sgid-demo /tmp/sticky-demo
```
Parada de verificacion (salida esperada):
```text
rm: cannot remove '/tmp/sticky-demo/f1': Operation not permitted
```
Explica que solo el dueno puede borrar aunque otros tengan escritura.

### 2) ACL POSIX con laboratorio local
**Idea clave**: ACL permite permisos por usuario/grupo y la mascara limita el permiso efectivo.

1. Aplicar ACL manualmente (modo guiado)
Tu explicas:
- "ACL explicita para lo existente + default ACL para lo nuevo."

Alumnos ejecutan:
```bash
setfacl -R -m g:grupo_datos:rwX -m u:profesor:rwX -m u:alumno1:rwX /srv/aso-ud4/compartida
setfacl -R -m d:g:grupo_datos:rwX -m d:u:profesor:rwX -m d:u:alumno1:rwX /srv/aso-ud4/compartida
sudo -u alumno1 touch /srv/aso-ud4/compartida/ok-alumno1
sudo -u profesor touch /srv/aso-ud4/compartida/ok-profesor
getfacl /srv/aso-ud4/compartida | head -n 25
```
Parada de verificacion (salida esperada):
```text
drwxrws---+ 2 root grupo_datos ...
user:alumno1:rwx
user:profesor:rwx
default:user:alumno1:rwx
```
Pausa aqui para explicar `mask` y `default ACL` con la salida de `getfacl`.
Explicacion breve:
- La `mask` es el **tope de permisos efectivos** para grupos y usuarios adicionales. Si la ACL dice `user:alumno1:rwx` pero `mask::r-x`, alumno1 queda en `r-x`.
- La `mask` **no** afecta al propietario (`user::`) ni a `other::`; solo recorta entradas de grupo y ACL adicionales.
- La `default ACL` se **hereda** en nuevos ficheros y directorios creados dentro del directorio.
- Sin `default ACL`, los nuevos ficheros heredan solo el modo POSIX (y el `setgid` si existe).
- Diferencia clave para clase: ACL normal actua en "lo que ya existe"; `default ACL` define "como nacera lo nuevo".
- `X` mayuscula en `rwX` evita marcar como ejecutables los ficheros normales: da `x` en directorios (y en ficheros que ya eran ejecutables), pero no en `.txt` recien creados.

2. Microdemo recomendada (2-3 min) para `default ACL` y `X`
Tu explicas:
- "El mismo `rwX` produce resultado distinto en archivo y directorio."

Alumnos ejecutan:
```bash
mkdir -p /tmp/default-acl-demo
chown root:grupo_datos /tmp/default-acl-demo
chmod 2770 /tmp/default-acl-demo
setfacl -m d:g:grupo_datos:rwX -m d:u:alumno1:rwX /tmp/default-acl-demo
sudo -u alumno1 touch /tmp/default-acl-demo/nota.txt
sudo -u alumno1 mkdir /tmp/default-acl-demo/carpeta
getfacl /tmp/default-acl-demo/nota.txt | head -n 20
getfacl /tmp/default-acl-demo/carpeta | head -n 20
```
Parada de verificacion (salida esperada):
```text
# file: /tmp/default-acl-demo/nota.txt
user:alumno1:rw-
group:grupo_datos:rw-

# file: /tmp/default-acl-demo/carpeta
user:alumno1:rwx
group:grupo_datos:rwx
```
Mensaje para remarcar:
- Mismo `rwX` heredado, resultado distinto segun tipo de objeto.
- Archivo normal: sin `x`.
- Directorio: con `x` para poder entrar/listar.

3. Prueba manual de mascara
Tu explicas:
- "La `mask` es el limite de permisos efectivos para grupo y ACL adicionales."

Alumnos ejecutan:
```bash
getfacl /srv/aso-ud4/compartida | head -n 20
setfacl -m m::r-x /srv/aso-ud4/compartida
getfacl /srv/aso-ud4/compartida | head -n 20
```
Parada de verificacion (salida esperada):
```text
mask::rwx
...
mask::r-x
```
Explica que la mascara recorta permisos efectivos aunque la ACL diga `rwx`.

### 3) Samba (SMB/CIFS) con permisos y ACL
**Idea clave**: Samba filtra por usuarios/grupos, pero el FS decide el permiso final.

Marco mental rapido (para explicar en 1 minuto):
- **Paso 1 - Autenticacion SMB:** valida usuario/contrasena.
- **Paso 2 - Reglas del share en Samba:** `valid users`, `read only`, `write list`.
- **Paso 3 - Linux FS (POSIX + ACL):** decide lectura/escritura/borrado real dentro del recurso.
- Resultado final:
  - Samba permite + FS permite -> funciona.
  - Samba permite + FS deniega -> veras `Access denied`.
  - Samba deniega -> ni siquiera entras al share.

1. Configurar `smb.conf` minimo en el servidor:
Tu explicas:
- "Samba puede permitir, pero si el FS/ACL deniega, el acceso final se deniega."

Alumnos ejecutan:
```bash
bash -c "cat >/etc/samba/smb.conf <<'EOF'
[global]
  workgroup = WORKGROUP
  security = user
  map to guest = never
  vfs objects = acl_xattr
  inherit permissions = yes

[compartida]
  path = /srv/aso-ud4/compartida
  read only = no
  create mask = 0660
  directory mask = 2770
  valid users = @grupo_datos
EOF"
```
Que significa cada directiva (resumen docente):
- `read only = no`: habilita escritura a nivel de share.
- `valid users = @grupo_datos`: solo miembros del grupo pueden autenticarse en ese recurso.
- `create mask` / `directory mask`: permisos maximos al crear por SMB (si son bajos, recortan colaboracion).

2. Crear usuario Samba y reiniciar servicio:
Tu explicas:
- "Primero alta en base Samba, luego validar config y reiniciar."

Alumnos ejecutan:
```bash
smbpasswd -a alumno1
testparm
systemctl restart smbd
```
Nota: en `smbpasswd` pon una contrasena simple para la demo (por ejemplo, `alumno1`).
3. Probar desde el cliente (shell `ud4-client`):
Alumnos ejecutan:
```bash
smbclient //ud4-lab/compartida -U alumno1
```
Parada de verificacion (salida esperada):
```text
Try "help" to get a list of possible commands.
smb: \>
```
4. Prueba de escritura y comprobacion en servidor:
Alumnos ejecutan:
```bash
# en cliente: abrir sesion SMB interactiva
smbclient //ud4-lab/compartida -U alumno1
```
Dentro del prompt `smb: \>` (esto ya no es la shell de Linux), ejecutar:
```text
put /etc/hosts ok-alumno1
ls
```
Nota docente:
- `put` **no se instala** como comando del sistema.
- `put` es un comando interno de `smbclient`, igual que `ls`, `get`, `cd`, etc.
- Si prefieres evitar modo interactivo, puedes hacerlo en una sola orden:
```bash
smbclient //ud4-lab/compartida -U alumno1 -c "put /etc/hosts ok-alumno1; ls"
```
```bash
# en servidor (ud4-lab)
ls -l /srv/aso-ud4/compartida
getfacl /srv/aso-ud4/compartida | head -n 20
```
Parada de verificacion (salida esperada):
```text
ok-alumno1 aparece en smbclient y en /srv/aso-ud4/compartida
```

5. Microfallo guiado (opcional, 2 min) para entender "Access denied":
Tu explicas:
- "Ahora Samba deja entrar, pero el FS recorta escritura con la mask ACL."
Alumnos ejecutan:
```bash
# servidor
setfacl -m m::r-x /srv/aso-ud4/compartida
getfacl /srv/aso-ud4/compartida | head -n 20
```
```bash
# cliente (dentro de smbclient)
put /etc/hosts falla-mask
```
Parada de verificacion (salida esperada):
```text
NT_STATUS_ACCESS_DENIED
```
```bash
# servidor (restaurar)
setfacl -m m::rwx /srv/aso-ud4/compartida
```

### 4) NFS con export y cliente
**Idea clave**: el servidor aplica ACL/UID/GID; el cliente solo ve el resultado.
- Orden real de evaluacion (igual que en teoria):
  1. El cliente monta una exportacion publicada por el servidor.
  2. El servidor identifica al usuario (`sec=sys` usa UID/GID numericos).
  3. El kernel del servidor aplica POSIX/ACL sobre la ruta exportada.

1. Exportar en el servidor:
Tu explicas:
- "Definimos export en servidor y recargamos con `exportfs -ra`."

Alumnos ejecutan:
```bash
# Precheck: en algunos contenedores LXD (rootfs idmapped sobre zfs) NFS kernel-server no funciona.
systemctl is-active nfs-kernel-server || true
findmnt -T /srv/aso-ud4/compartida -o TARGET,SOURCE,FSTYPE,OPTIONS

# Red real del contenedor (evita hardcodear 10.0.0.0/24)
NET=$(ip -4 route show dev eth0 | awk '/proto kernel/ {print $1; exit}')
echo "Red detectada: $NET"
grep -q '^/srv/aso-ud4/compartida ' /etc/exports || echo "/srv/aso-ud4/compartida $NET(rw,sync,subtree_check,acl,root_squash)" >> /etc/exports
exportfs -ra
exportfs -v
```
Si `systemctl is-active` devuelve `inactive` o `findmnt` muestra `idmapped`/`zfs`, el NFS kernel-server puede no ser viable en este contenedor.
En ese caso, recrea el entorno con `./docs/UD4/lab/ud4_lab.sh cleanup` y `./docs/UD4/lab/ud4_lab.sh setup` (el script ya prepara el contenedor para NFS).
Parada de verificacion (salida esperada):
```text
/srv/aso-ud4/compartida <tu_red>(...)
```
2. Montar desde el cliente (shell `ud4-client`):
Alumnos ejecutan:
```bash
mkdir -p /mnt/comp
mount -t nfs ud4-lab:/srv/aso-ud4/compartida /mnt/comp
ls -la /mnt/comp
```
Parada de verificacion (salida esperada):
```text
drwxrws---+ 2 root grupo_datos ...
```

3. Comprobacion rapida de diagnostico (coherente con teoria):
Alumnos ejecutan:
```bash
# servidor (ud4-lab)
exportfs -v

# cliente (ud4-client)
showmount -e ud4-lab
mount | grep nfs

# comprobar identidad en ambos lados
id alumno1
getent passwd alumno1
```
Mensaje docente:
- Si UID/GID no cuadran entre cliente y servidor en `sec=sys`, habra "Permission denied" aunque el nombre de usuario sea el mismo.

### 5) Nextcloud (demo opcional fuera de tiempo base)
**Idea clave**: Nextcloud gestiona comparticion logica, pero el FS manda.

1. Instalar en el servidor:
Tu explicas:
- "En clase lo dejamos como demo opcional para no romper tiempos."

Alumnos ejecutan:
```bash
snap install nextcloud
```
Parada de verificacion (salida esperada):
```text
nextcloud ... installed
```
2. Mostrar estado:
Alumnos ejecutan:
```bash
nextcloud.status
```
Parada de verificacion (salida esperada):
```text
installed: true
```
3. (Opcional) Crear usuario admin y mostrar acceso local:
Alumnos ejecutan:
```bash
nextcloud.manual-install admin admin123
nextcloud.occ user:list
```
Parada de verificacion (salida esperada):
```text
admin
```

### 6) Limpieza final (opcional)
```bash
./docs/UD4/lab/ud4_lab.sh cleanup
```

## Checklist de mensajes clave para el alumnado
- SUID/SGID/sticky cambian el comportamiento sin cambiar el rwx basico.
- En ACL, la `mask` manda sobre permisos efectivos.
- `default ACL` define herencia; sin ella, solo heredan los permisos POSIX.
- En servicios de red, el permiso final depende del sistema de ficheros.
- Este guion usa LXD para practicar rapido; la entrega UD4 se valida con el laboratorio integrado de `actividades.md`.

## Preguntas rapidas para cerrar
- Que diferencia hay entre SGID en binario y en directorio?
- Por que una ACL `rwx` puede acabar en `r-x`?
- Que pasa si Samba permite y el FS deniega?
