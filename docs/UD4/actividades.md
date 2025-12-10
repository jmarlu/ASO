# 🔧 Actividades – ACL en sistemas de ficheros (Integración de servicios)

## Nivel 1 – Fundamentos

1. **Comprueba soporte ACL**  
   - Muestra con `mount` o `tune2fs` si tu FS tiene `acl`.  
   - Si no aparece, remonta con `acl` y captura el antes/después.

2. **Lectura de ACL**  
   - Crea `~/demo-acl` y dos archivos.  
   - Ejecuta `getfacl` y explica qué significa la `mask`.

## Nivel 2 – Aplicación

3. **Proyecto compartido**  
   - Crea `/srv/proyecto` con dueño `root:proyecto` y `chmod 2770`.  
   - ACL: grupo `equipo` rwX, usuario `ana` rX, usuario `luis` rwX, defaults coherentes.  
   - Valida con `touch` como cada usuario (usa `sudo -u`) y demuestra herencia.

4. **Limpieza y reversión**  
   - Quita todas las ACL de `/srv/proyecto` con `setfacl -b` y muestra cómo vuelve al modo POSIX clásico.

## Nivel 3 – Integración con servicios

5. **Samba o NFS**  
   - Exporta `/srv/proyecto` por Samba *o* NFS.  
   - Muestra que desde el cliente se respetan las ACL (intenta escribir con un usuario permitido y uno denegado).

6. **Auditoría rápida**  
   - Escribe un script que liste directorios con `+` en `ls -l` bajo `/srv` y saque `getfacl` de cada uno a un log con sello de fecha.

## Nivel 4 – Reto opcional

7. **Reto Ansible (ACL de red)**  
   - Escribe un playbook que configure una ACL en routers/switches Cisco (o emulados) usando un `template` y `when` por host_vars.  
   - Incluye tarea de validación (por ejemplo, `ios_command` que muestre la ACL aplicada).  
   - Entrega inventario, playbook y salida de ejecución.

---

# 🧪 Laboratorio integrado (LDAP Docker + Fileserver LXD con ACL, NFS/Samba)

Objetivo: identidad central en LDAP (Docker, con TLS), servidor de ficheros en LXD que resuelve usuarios LDAP, crea homes al vuelo y expone una carpeta compartida con ACL, accesible por NFS y/o Samba.

1. **Preparar fileserver en LXD**  
   - Crea contenedor Ubuntu con `security.nesting=true`.  
   - Instala `sssd-ldap libpam-sss libnss-sss ldap-utils acl`.  
   - Configura `/etc/sssd/sssd.conf` con tu `ldap_uri = ldaps://<IP LDAP>:636`, `ldap_tls_cacert = /etc/ssl/certs/ca-ldap.crt`, `ldap_search_base = dc=...`.  
   - `chmod 600 /etc/sssd/sssd.conf`, `systemctl enable --now sssd`.  
   - PAM: añade `session required pam_mkhomedir.so skel=/etc/skel umask=077` a `common-session`.  
   - Verifica: `getent passwd alumno1` devuelve UID/GID LDAP.

2. **Homes y carpeta compartida con ACL**  
   - Crea base de homes `/home/usuarios` (755).  
   - Crea `/srv/compartida` con `chown root:equipo`, `chmod 2770`, default ACL `setfacl -m d:g:equipo:rwX /srv/compartida` y ACL explícita `setfacl -m g:equipo:rwX /srv/compartida`.  
   - Prueba: `su - alumno1` crea `/home/usuarios/alumno1` 700; `sudo -u alumno1 touch /srv/compartida/ok` funciona; usuario fuera de `equipo` falla.

3. **Exporta por NFS**  
   - `/etc/exports` ejemplo:  
     `/srv/compartida 10.0.0.0/24(rw,sync,subtree_check,acl,root_squash,fsid=0)`  
     `/home/usuarios  10.0.0.0/24(rw,sync,subtree_check,acl,root_squash)`  
   - Reinicia `nfs-kernel-server`.  
   - Cliente: `mount -t nfs filesrv:/srv/compartida /mnt/comp` y prueba escritura/denegación según ACL.

4. **Exporta por Samba (opcional o alternativo)**  
   - Instala `samba`; añade a `smb.conf`:  
     `[global] security = user; vfs objects = acl_xattr; inherit permissions = yes`  
     `[compartida] path = /srv/compartida; read only = no; create mask = 0660; directory mask = 2770; valid users = @equipo`  
     `[homes] browseable = no; read only = no; create mask = 0600; directory mask = 0700`  
   - `testparm` y `systemctl restart smbd`.  
   - Cliente: `smbclient //filesrv/compartida -U alumno1` (ok) y prueba con usuario fuera de grupo (denegado).

5. **Validaciones finales**  
   - `openssl s_client -connect <IP LDAP>:636 -CAfile ca-ldap.crt` (TLS ok).  
   - `getent passwd`/`group` de varios usuarios/grupos LDAP.  
   - `ls -ld /srv/compartida` → `drwxrws---+`; `getfacl /srv/compartida` muestra defaults.  
   - Pruebas de acceso desde cliente NFS/Samba según pertenencia a `equipo`.

6. **Entrega**  
   - Capturas/comandos de: configuración `sssd.conf` (sin contraseñas), `getent`, creación de home, `getfacl` de `/srv/compartida`, prueba ok/fallo en escritura, montaje NFS o acceso SMB, y comprobación de TLS LDAP.
