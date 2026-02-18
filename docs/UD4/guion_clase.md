---
search:
  exclude: true
---

# Guion de clase UD4 - Permisos especiales, ACL y recursos compartidos

## Objetivo de la sesion
- Comprender SUID, SGID y sticky bit con ejemplos reales.
- Manejar ACL POSIX y explicar la mascara y la herencia.
- Conectar ACL con NFS/Samba/Nextcloud a nivel conceptual.

## Requisitos previos (5 min)
- Sistema Linux con sudo.
- LXD instalado e inicializado (laboratorio en contenedor).
  - Instalar: `sudo apt install lxd`
  - Inicializar: `sudo lxd init`
- Los servicios (ACL, Samba, NFS, Nextcloud) se ejecutan dentro del contenedor.

## Material preparado en este repo
- Script de laboratorio: `docs/UD4/lab/ud4_lab.sh`.
- Teoria actualizada: `docs/UD4/teoria.md`.

## Estructura y tiempos sugeridos (50-60 min)
1. Introduccion y objetivos (5 min)
2. SUID/SGID/Sticky con demo rapida (15 min)
3. ACL POSIX y mascara (15 min)
4. Puente a Samba/NFS/Nextcloud (10 min)
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

### 1) SUID, SGID, sticky bit
**Idea clave**: los bits especiales cambian el comportamiento del sistema de permisos.

1. SUID
Tu explicas:
- "SUID en binarios: el proceso corre con el UID del propietario del binario."

Alumnos ejecutan:
```bash
# Nota: si /tmp tiene "nosuid", usa /usr/local/bin en lugar de /tmp.
lxc exec ud4-lab -- cp /bin/ping /tmp/ping-suid
lxc exec ud4-lab -- chown root:root /tmp/ping-suid
lxc exec ud4-lab -- chmod 4755 /tmp/ping-suid
lxc exec ud4-lab -- ls -l /tmp/ping-suid
lxc exec ud4-lab -- bash -c "sudo -u alumno1 id -u"
lxc exec ud4-lab -- bash -c "sudo -u alumno1 /tmp/ping-suid -c1 127.0.0.1"
lxc exec ud4-lab -- rm /tmp/ping-suid
```
Parada de verificacion (salida esperada):
```text
-rwsr-xr-x 1 root root ... /tmp/ping-suid
<UID de alumno1, distinto de 0>
1 packets transmitted, 1 received, 0% packet loss
```
Explica que el binario se ejecuta como root y por eso funciona sin sudo.

2. SGID en directorio
Tu explicas:
- "SGID en directorios fuerza herencia de grupo en ficheros nuevos."

Alumnos ejecutan:
```bash
lxc exec ud4-lab -- groupadd -f grupo_datos
lxc exec ud4-lab -- mkdir -p /tmp/sgid-demo
lxc exec ud4-lab -- chown root:grupo_datos /tmp/sgid-demo
lxc exec ud4-lab -- chmod 2775 /tmp/sgid-demo
lxc exec ud4-lab -- usermod -aG grupo_datos alumno1
lxc exec ud4-lab -- bash -c "sudo -u alumno1 touch /tmp/sgid-demo/archivo"
lxc exec ud4-lab -- ls -l /tmp/sgid-demo/archivo
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
lxc exec ud4-lab -- mkdir -p /tmp/sticky-demo
lxc exec ud4-lab -- chmod 1777 /tmp/sticky-demo
lxc exec ud4-lab -- touch /tmp/sticky-demo/f1
lxc exec ud4-lab -- bash -c "sudo -u nobody touch /tmp/sticky-demo/f2"
lxc exec ud4-lab -- bash -c "sudo -u nobody rm /tmp/sticky-demo/f1"
lxc exec ud4-lab -- bash -c "sudo -u nobody rm /tmp/sticky-demo/f2"
lxc exec ud4-lab -- rm -r /tmp/sgid-demo /tmp/sticky-demo
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
lxc exec ud4-lab -- bash -c "setfacl -R -m g:grupo_datos:rwX -m u:profesor:rwX -m u:alumno1:rwX /srv/aso-ud4/compartida"
lxc exec ud4-lab -- bash -c "setfacl -R -m d:g:grupo_datos:rwX -m d:u:profesor:rwX -m d:u:alumno1:rwX /srv/aso-ud4/compartida"
lxc exec ud4-lab -- bash -c "sudo -u alumno1 touch /srv/aso-ud4/compartida/ok-alumno1"
lxc exec ud4-lab -- bash -c "sudo -u profesor touch /srv/aso-ud4/compartida/ok-profesor"
lxc exec ud4-lab -- getfacl /srv/aso-ud4/compartida | head -n 25
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
lxc exec ud4-lab -- mkdir -p /tmp/default-acl-demo
lxc exec ud4-lab -- chown root:grupo_datos /tmp/default-acl-demo
lxc exec ud4-lab -- chmod 2770 /tmp/default-acl-demo
lxc exec ud4-lab -- setfacl -m d:g:grupo_datos:rwX -m d:u:alumno1:rwX /tmp/default-acl-demo
lxc exec ud4-lab -- bash -c "sudo -u alumno1 touch /tmp/default-acl-demo/nota.txt"
lxc exec ud4-lab -- bash -c "sudo -u alumno1 mkdir /tmp/default-acl-demo/carpeta"
lxc exec ud4-lab -- getfacl /tmp/default-acl-demo/nota.txt | head -n 20
lxc exec ud4-lab -- getfacl /tmp/default-acl-demo/carpeta | head -n 20
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
lxc exec ud4-lab -- getfacl /srv/aso-ud4/compartida | head -n 20
lxc exec ud4-lab -- setfacl -m m::r-x /srv/aso-ud4/compartida
lxc exec ud4-lab -- getfacl /srv/aso-ud4/compartida | head -n 20
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

1. Configurar `smb.conf` minimo en el servidor:
Tu explicas:
- "Samba puede permitir, pero si el FS/ACL deniega, el acceso final se deniega."

Alumnos ejecutan:
```bash
lxc exec ud4-lab -- bash -c "cat >/etc/samba/smb.conf <<'EOF'
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
2. Crear usuario Samba y reiniciar servicio:
Tu explicas:
- "Primero alta en base Samba, luego validar config y reiniciar."

Alumnos ejecutan:
```bash
lxc exec ud4-lab -- smbpasswd -a alumno1
lxc exec ud4-lab -- testparm
lxc exec ud4-lab -- systemctl restart smbd
```
Nota: en `smbpasswd` pon una contrasena simple para la demo (por ejemplo, `alumno1`).
3. Probar desde el cliente:
Alumnos ejecutan:
```bash
lxc exec ud4-client -- smbclient //ud4-lab/compartida -U alumno1
```
Parada de verificacion (salida esperada):
```text
Try "help" to get a list of possible commands.
smb: \>
```

### 4) NFS con export y cliente
**Idea clave**: el servidor aplica ACL/UID/GID; el cliente solo ve el resultado.

1. Exportar en el servidor:
Tu explicas:
- "Definimos export en servidor y recargamos con `exportfs -ra`."

Alumnos ejecutan:
```bash
lxc network show lxdbr0 | grep ipv4.address
lxc exec ud4-lab -- bash -c "grep -q '^/srv/aso-ud4/compartida ' /etc/exports || echo '/srv/aso-ud4/compartida 10.0.0.0/24(rw,sync,subtree_check,acl,root_squash)' >> /etc/exports"
lxc exec ud4-lab -- exportfs -ra
lxc exec ud4-lab -- exportfs -v
```
Si tu red LXD no es `10.0.0.0/24`, sustituye el prefijo por el que muestre `lxdbr0`.
Parada de verificacion (salida esperada):
```text
/srv/aso-ud4/compartida 10.0.0.0/24(...)
```
2. Montar desde el cliente:
Alumnos ejecutan:
```bash
lxc exec ud4-client -- mkdir -p /mnt/comp
lxc exec ud4-client -- mount -t nfs ud4-lab:/srv/aso-ud4/compartida /mnt/comp
lxc exec ud4-client -- ls -la /mnt/comp
```
Parada de verificacion (salida esperada):
```text
drwxrws---+ 2 root grupo_datos ...
```

### 5) Nextcloud (demo rapida)
**Idea clave**: Nextcloud gestiona comparticion logica, pero el FS manda.

1. Instalar en el servidor:
Tu explicas:
- "En clase lo dejamos como demo opcional para no romper tiempos."

Alumnos ejecutan:
```bash
lxc exec ud4-lab -- snap install nextcloud
```
Parada de verificacion (salida esperada):
```text
nextcloud ... installed
```
2. Mostrar estado:
Alumnos ejecutan:
```bash
lxc exec ud4-lab -- nextcloud.status
```
Parada de verificacion (salida esperada):
```text
installed: true
```
3. (Opcional) Crear usuario admin y mostrar acceso local:
Alumnos ejecutan:
```bash
lxc exec ud4-lab -- nextcloud.manual-install admin admin123
lxc exec ud4-lab -- nextcloud.occ user:list
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

## Preguntas rapidas para cerrar
- Que diferencia hay entre SGID en binario y en directorio?
- Por que una ACL `rwx` puede acabar en `r-x`?
- Que pasa si Samba permite y el FS deniega?
