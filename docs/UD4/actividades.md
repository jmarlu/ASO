# 🔧 Actividades – ACL en sistemas de ficheros (Integracion de servicios)

## Contexto del laboratorio general (UD3 → UD4)
Trabajaremos con el **mismo esquema de red y VMs** que en el laboratorio general:
- Red privada VirtualBox: `10.50.0.0/24`
- VM-SERVIDOR: `10.50.0.10` (Docker OpenLDAP con StartTLS)
- Fileserver en LXD: `10.50.0.11` (Samba + SSSD/LDAP)
- VM-CLIENTE: `10.50.0.20` (GUI + pruebas de acceso)

Este apartado de UD4 **continua** lo que se monto en UD3: LDAP en Docker y autenticacion LDAP via SSSD, ahora aplicados a ACL y Samba.
Regla practica: **configuracion en VM-SERVIDOR/LXD** y **pruebas de acceso en VM-CLIENTE**.

## Nivel 1 – Fundamentos

1. **Comprueba soporte ACL (VM-CLIENTE, local)**
   - Muestra con `mount` o `tune2fs` si tu FS tiene `acl`.
   - Si no aparece, remonta con `acl` y captura el antes/despues.

2. **Lectura de ACL (VM-CLIENTE, local)**
   - Crea `~/demo-acl` y dos archivos.
   - Ejecuta `getfacl` y explica que significa la `mask`.

## Nivel 2 – Aplicacion

3. **Proyecto compartido (VM-CLIENTE, local)**
   - Crea `/srv/grupo_clase` con propietario `root:grupo_datos` y `chmod 2770`.
   - ACL: grupos `alumnos` y `profesores` con `rwX`, defaults coherentes.
   - Valida con `touch` como cada usuario (usa `sudo -u`) y demuestra herencia.

4. **Limpieza y reversion (VM-CLIENTE, local)**
   - Quita todas las ACL de `/srv/grupo_clase` con `setfacl -b` y muestra como vuelve al modo POSIX clasico.

5. **Bits especiales: setgid y sticky (VM-CLIENTE, local)**
   - Crea `/srv/practica_setgid` con `chown root:grupo_datos` y `chmod 2770`.
   - Crea un fichero como `alumno1` y comprueba que hereda el grupo (`ls -l`).
   - Crea `/srv/publico` con `chmod 1777` y prueba que un usuario no puede borrar ficheros de otro.

6. **Umask y mascara ACL (VM-CLIENTE, local)**
   - Fija `umask 077` y crea un fichero dentro de `/srv/grupo_clase`.
   - Aplica `setfacl -m d:g:alumnos:rwX -m d:g:profesores:rwX /srv/grupo_clase` y crea otro fichero.
   - Compara `getfacl` y explica el efecto de la `mask` en permisos efectivos.

## Nivel 3 – Integracion con servicios

7. **Fileserver en LXD (Samba + SSSD/LDAP)**
   - Crea el contenedor fileserver `10.50.0.11` y valida `getent passwd profesor` y `getent passwd alumno1`.
   - Configura Samba en el fileserver.
   - Prepara dos recursos:
     - `/srv/grupo_clase` (ACL para `alumnos` y `profesores`).
     - `/srv/home/alumno1` con ACL para que `profesor` pueda entrar.

8. **Samba (pruebas en VM-CLIENTE)**
   - Accede a `//10.50.0.11/grupo_clase` con `alumno1` y comprueba escritura:
     - `smbclient //10.50.0.11/grupo_clase -U alumno1`
     - dentro de smbclient: `put /etc/hosts ok-alumno1`
   - Accede a `//10.50.0.11/grupo_clase` con `profesor` y comprueba escritura:
     - `smbclient //10.50.0.11/grupo_clase -U profesor`
     - dentro de smbclient: `put /etc/hosts ok-profesor`
   - Acceso a homes:
     - `smbclient //10.50.0.11/alumno1 -U alumno1` (ok)
     - `smbclient //10.50.0.11/alumno1 -U profesor` (ok por ACL)
     - `smbclient //10.50.0.11/profesor -U alumno1` (debe denegar)

9. **Auditoria rapida (VM-SERVIDOR o fileserver)**
   - Escribe un script que liste directorios con `+` en `ls -l` bajo `/srv` y saque `getfacl` de cada uno a un log con sello de fecha.

---

# 🧪 Laboratorio integrado (LDAP Docker + Fileserver LXD con ACL y Samba)

Objetivo: identidad central en LDAP (Docker con StartTLS), servidor de ficheros en LXD que resuelve usuarios LDAP, crea homes al vuelo y expone compartidos con ACL accesibles por Samba.

1. **Preparar fileserver en LXD**
   - En la **VM-SERVIDOR (10.50.0.10)** crea un contenedor Ubuntu con `security.nesting=true` y IP fija `10.50.0.11`.
   - Instala `sssd-ldap libpam-sss libnss-sss ldap-utils acl`.
   - Configura `/etc/sssd/sssd.conf` con:
     - `ldap_uri = ldap://10.50.0.10:389`
     - `ldap_id_use_start_tls = true`
     - `ldap_tls_cacert = /etc/ssl/certs/ca-ldap.crt`
     - `ldap_search_base = dc=...`
   - `chmod 600 /etc/sssd/sssd.conf`, `systemctl enable --now sssd`.
   - PAM: anade `session required pam_mkhomedir.so skel=/etc/skel umask=077` a `common-session`.
   - Verifica: `getent passwd alumno1` devuelve UID/GID LDAP.

2. **Homes y carpetas con ACL (fileserver LXD)**
   - Crea base de homes `/home/usuarios` (755).
   - Crea `/srv/grupo_clase` con `chown root:grupo_datos`, `chmod 2770`, default ACL `setfacl -m d:g:alumnos:rwX -m d:g:profesores:rwX /srv/grupo_clase` y ACL explicita `setfacl -m g:alumnos:rwX -m g:profesores:rwX /srv/grupo_clase`.
   - Crea `/srv/home/alumno1` (si no existe) y aplica ACL para `profesor`:
     - `setfacl -m u:profesor:rwx /srv/home/alumno1`
     - `setfacl -m d:u:profesor:rwx /srv/home/alumno1`
   - En el **fileserver**, prueba: `su - alumno1` crea `/home/usuarios/alumno1` 700; `sudo -u alumno1 touch /srv/grupo_clase/ok` funciona; `sudo -u alumno1 touch /srv/home/alumno1/privado` funciona; `sudo -u alumno1 touch /srv/home/profesor/fallo` falla.

3. **Exporta por Samba**
   - Instala `samba`; anade a `smb.conf`:
     - `[global] security = user; vfs objects = acl_xattr; inherit permissions = yes`
     - `[grupo_clase] path = /srv/grupo_clase; read only = no; create mask = 0660; directory mask = 2770; valid users = @alumnos @profesores`
     - `[homes] browseable = no; read only = no; create mask = 0600; directory mask = 0700`
   - `testparm` y `systemctl restart smbd`.
   - En la **VM-CLIENTE**:
     - `smbclient //10.50.0.11/grupo_clase -U alumno1` (ok).
     - `smbclient //10.50.0.11/alumno1 -U alumno1` (ok).
     - `smbclient //10.50.0.11/alumno1 -U profesor` (ok por ACL).
     - `smbclient //10.50.0.11/profesor -U alumno1` (denegado).

4. **NFS en el fileserver (carpeta separada, sin afectar a Samba)**
   - En el **fileserver LXD**, crea una carpeta solo para NFS:
     - `/srv/nfs_local` con `chown root:root` y `chmod 755`.
   - Exporta solo esa ruta en `/etc/exports`:
     - `/srv/nfs_local 10.50.0.0/24(rw,sync,no_subtree_check,root_squash)`
   - Reinicia `nfs-kernel-server` y verifica con `exportfs -v`.
   - Prueba desde la **VM-SERVIDOR** o **VM-CLIENTE**:
     - `mount -t nfs 10.50.0.11:/srv/nfs_local /mnt/nfs_local`
   - Confirma que `/srv/grupo_clase` y `/srv/home` no cambian ni se ven afectadas.

5. **Validaciones finales**
   - `openssl s_client -connect 10.50.0.10:389 -starttls ldap -CAfile ca-ldap.crt` (StartTLS ok).
   - En el **fileserver**, `getent passwd`/`group` de varios usuarios/grupos LDAP.
   - En el **fileserver**, `ls -ld /srv/grupo_clase /srv/home/alumno1` → `drwxrws---+`; `getfacl` muestra defaults.
   - En la **VM-CLIENTE**, pruebas de acceso Samba segun pertenencia a `alumnos` y `profesores`.

6. **Automontaje de carpetas (homes y grupo_clase)**
   - En la **VM-CLIENTE**: `profesor` monta `//10.50.0.11/grupo_clase` y `//10.50.0.11/alumno1`; `alumno1` solo `//10.50.0.11/grupo_clase`.
   - Opcion A (autofs + CIFS):
     - Crea `/etc/auto.master` y un mapa `/etc/auto.cifs` con entradas por usuario.
     - Usa credenciales por usuario o un fichero de credenciales diferente para cada uno.
     - Verifica que al acceder a `/home/profesor/grupo_clase` y `/home/profesor/alumno1` se montan automaticamente, y que `alumno1` solo monta `/home/alumno1/grupo_clase`.
   - Opcion B (fstab + systemd automount):
     - Define entradas con `x-systemd.automount,_netdev` y credenciales separadas.
     - Comprueba el montaje bajo demanda con `ls` en los puntos de montaje.
   - Comprobacion rapida:
     - `ls /home/profesor/grupo_clase` y `ls /home/profesor/alumno1`
     - `ls /home/alumno1/grupo_clase` y `ls /home/alumno1/profesor` (debe fallar).

7. **Entrega**
   - Capturas/comandos de: configuracion `sssd.conf` (sin contrasenas), `getent`, creacion de home, `getfacl` de `/srv/grupo_clase`, pruebas ok/fallo en escritura, acceso SMB desde la VM-CLIENTE y comprobacion de TLS LDAP.
   - Evidencias del automontaje para `profesor` y `alumno1`.
