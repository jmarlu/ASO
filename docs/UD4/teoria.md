
# Permisos especiales en Linux (SUID, SGID, sticky bit)
- Objetivo: entender que los bits especiales cambian el comportamiento de permisos y ver un ejemplo practico de cada uno.
- Resultado esperado: saber identificar SUID/SGID/sticky en un `ls -l` y explicar su impacto en un entorno multiusuario.

## Idea clave
Los bits especiales son tres banderas adicionales al `rwx` clasico. Modifican **quien** ejecuta un programa o **quien** puede borrar en un directorio. Se representan con el primer digito del modo en octal:

- `4xxx` SUID, `2xxx` SGID, `1xxx` sticky.
- Ejemplo: `4755` equivale a `rwsr-xr-x`.

## Como se ven en `ls -l`
- SUID aparece en el permiso de **usuario**: `s` si hay ejecucion (`rws`), `S` si no hay ejecucion.
- SGID aparece en el permiso de **grupo**: `s` / `S`.
- Sticky aparece en el permiso de **otros**: `t` si hay ejecucion, `T` si no hay ejecucion.

## Comportamiento resumido
- **SUID (setuid, 4xxx)** en **binarios**: se ejecutan con el **UID del dueño** del fichero. Ejemplo clasico: `passwd` (permite escribir `/etc/shadow`).
- **SGID (setgid, 2xxx)**:
  - En **binarios**: se ejecutan con el **GID del dueño**.
  - En **directorios**: los nuevos ficheros heredan el **grupo** del directorio (no del usuario creador).
- **Sticky bit (1xxx)** en **directorios**: solo el dueño del fichero (o root) puede borrarlo/renombrarlo aunque otros tengan escritura. Ejemplo: `/tmp`.

## Comandos utiles
- Ver permisos: `ls -l` y `stat -c "%a %n" ruta`.
- Buscar bits especiales:
  - SUID: `find / -perm -4000 -type f 2>/dev/null`
  - SGID: `find / -perm -2000 -type f 2>/dev/null`
  - Sticky en directorios: `find / -perm -1000 -type d 2>/dev/null`

## Nota de seguridad
- SUID/SGID en binarios permiten **escalar privilegios**; deben usarse solo en binarios confiables y con permisos estrictos.
- En sistemas con `/tmp` montado con `nosuid`, los binarios SUID alli **no** elevan privilegios.

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
   id -u                         # UID real (tu usuario)
   /tmp/ping-suid -c1 127.0.0.1   # EUID esperado: 0 (root)
   ```
   Verificacion real de UID/GID efectivos con un binario propio:
   ```bash
   cat > /tmp/ruid.c <<'EOF'
   #include <stdio.h>
   #include <unistd.h>
   int main(void) {
     printf("ruid=%d euid=%d rgid=%d egid=%d\n",
            getuid(), geteuid(), getgid(), getegid());
     return 0;
   }
   EOF
   gcc /tmp/ruid.c -o /tmp/ruid
   /tmp/ruid                 # ruid=TU_UID euid=TU_UID
   sudo chown root:root /tmp/ruid
   sudo chmod 4755 /tmp/ruid
   /tmp/ruid                 # ruid=TU_UID euid=0
   ```
   *Recuerda limpiar*: `sudo rm /tmp/ping-suid`.
2. **SGID en directorio** (herencia de grupo):
   ```bash
   sudo groupadd grupo_datos
   sudo mkdir /tmp/sgid-demo
   sudo chown root:grupo_datos /tmp/sgid-demo
   sudo chmod 2775 /tmp/sgid-demo   # drwxrwsr-x (s en group)
   sudo usermod -aG grupo_datos $(whoami)  # añade tu usuario al grupo
   newgrp grupo_datos                       # activa el grupo en esta shell
   id -g -n                                 # GID efectivo de la shell
   touch /tmp/sgid-demo/archivo
   ls -l /tmp/sgid-demo/archivo     # grupo debe ser 'grupo_datos'
   ```
3. **Sticky bit**:
   ```bash
   sudo mkdir /tmp/sticky-demo
   sudo chmod 1777 /tmp/sticky-demo   # rwxrwxrwt (t)
   sudo touch /tmp/sticky-demo/f1
   sudo -u nobody id -u -n            # UID efectivo: nobody
   sudo -u nobody touch /tmp/sticky-demo/f2
   sudo -u nobody rm /tmp/sticky-demo/f1   # debe FALLAR (no es dueño)
   sudo -u nobody rm /tmp/sticky-demo/f2   # debe funcionar (es dueño)
   sudo -u $(whoami) rm /tmp/sticky-demo/f2 #debe fallar (no eres dueño de f2)
   ```
   *Limpieza*: `sudo rm -r /tmp/sgid-demo /tmp/sticky-demo`.

# 🗂️ ACL en sistemas de ficheros (GNU/Linux)

> “Compartir sin romper la seguridad: mismo recurso, permisos granulados.”

## Convencion de escenarios UD4
- Para evitar confusion entre documentos, en UD4 se usan dos escenarios:
  - **Guion de clase** (`docs/UD4/guion_clase.md`): servidor `ud4-lab`, cliente `ud4-client`, recurso `/srv/aso-ud4/compartida`, share SMB `compartida`.
  - **Actividades evaluables** (`docs/UD4/actividades.md`): fileserver `10.50.0.11`, recurso `/srv/grupo_clase`, share SMB `grupo_clase`.
- La logica de permisos es la misma en ambos; solo cambian nombres de host/ruta y el entorno de ejecucion.

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

### Default ACL en detalle (herencia real)

- Una ACL "normal" (`u:ana:rw-`) afecta al objeto actual.
- Una `default ACL` (`d:u:ana:rwX`) solo tiene efecto en directorios y se copia a lo nuevo que se cree dentro.
- Si no defines `default ACL`, cada archivo nuevo nace con permisos desde `umask` y modo POSIX, no desde ACL heredada.

Ejemplo minimo:
```bash
sudo mkdir -p /srv/acl-demo
sudo chown root:grupo_datos /srv/acl-demo
sudo chmod 2770 /srv/acl-demo
sudo setfacl -m d:g:grupo_datos:rwX -m d:u:profesor:rwX /srv/acl-demo
getfacl /srv/acl-demo
```

Salida esperada (resumen):
```text
default:user::rwx
default:user:profesor:rwx
default:group:grupo_datos:rwx
default:mask::rwx
default:other::---
```

Comprobacion de herencia:
```bash
sudo -u profesor touch /srv/acl-demo/fichero.txt
sudo -u profesor mkdir /srv/acl-demo/carpeta
getfacl /srv/acl-demo/fichero.txt
getfacl /srv/acl-demo/carpeta
```

Que debes ver:
- En `fichero.txt`, `profesor` y `grupo_datos` tendran `rw-` (sin `x`).
- En `carpeta`, `profesor` y `grupo_datos` tendran `rwx`.
- Conclusión: la herencia viene de `default:*` del directorio padre.

### Por que aparece `X` mayuscula

- `x` minuscula siempre intenta poner ejecucion.
- `X` mayuscula es "ejecucion condicional":
  - Se aplica siempre a directorios.
  - En archivos normales, solo se aplica si ese archivo ya tenia `x`.
- Se usa en ACL recursivas para no convertir documentos en ejecutables por error.

Ejemplo practico (`x` vs `X`):
```bash
sudo mkdir -p /srv/x-demo
sudo touch /srv/x-demo/a.txt
sudo chmod 644 /srv/x-demo/a.txt
sudo setfacl -m u:alumno1:rwX /srv/x-demo/a.txt
getfacl /srv/x-demo/a.txt | grep alumno1
sudo setfacl -m u:alumno1:rwx /srv/x-demo/a.txt
getfacl /srv/x-demo/a.txt | grep alumno1
```

Interpretacion:
- Con `rwX`, `a.txt` queda en `rw-` para `alumno1`.
- Con `rwx`, `a.txt` pasa a `rwx`.
- En directorios, tanto `x` como `X` suelen acabar dando acceso de travesia, pero `X` evita permisos de ejecucion innecesarios en archivos.

### La máscara en ACL POSIX

- Define el **máximo** de permisos efectivos para todas las entradas **que no sean el dueño** (grupos y usuarios adicionales).
- Si añades `u:alumno1:rwx` pero la `mask::r-x`, alumno1 solo tendrá `r-x` hasta que subas la máscara.
- Comandos útiles:
  ```bash
  getfacl archivo            # ver mask
  setfacl -m m::rwx archivo  # ajustar máscara
  ```
- Al modificar ACL, la máscara puede bajar automáticamente; revisa tras cambios.

### Permisos efectivos (base POSIX/ACL)
- Regla rapida: **permiso efectivo = ACL ∩ mask ∩ POSIX** (para grupo y entradas ACL adicionales; en el propietario no aplica `mask`).
- No basta con "tener una ACL": para escribir en un archivo dentro de un directorio necesitas:
  - permiso de escritura en el archivo, y
  - permiso de travesia (`x`) en el directorio.

Casos tipicos (con ejemplo):

1. **ACL permite, pero `mask` recorta**
   ```bash
   sudo touch /srv/demo.txt
   sudo chown root:grupo_datos /srv/demo.txt
   sudo chmod 660 /srv/demo.txt
   sudo setfacl -m u:alumno1:rwx /srv/demo.txt
   sudo setfacl -m m::r-x /srv/demo.txt
   getfacl /srv/demo.txt
   ```
   Resultado esperado:
   - Veras `user:alumno1:rwx    #effective:r-x`.
   - `alumno1` podra leer, pero no escribir.

2. **Archivo con permisos correctos, pero sin `x` en el directorio**
   ```bash
   sudo mkdir -p /srv/sin_travesia
   sudo chmod 700 /srv/sin_travesia
   sudo setfacl -m u:alumno1:r-- /srv/sin_travesia
   sudo touch /srv/sin_travesia/f.txt
   sudo setfacl -m u:alumno1:rw- /srv/sin_travesia/f.txt
   sudo -u alumno1 cat /srv/sin_travesia/f.txt
   ```
   Resultado esperado:
   - Falla por falta de travesia del directorio (`x` en `/srv/sin_travesia`), aunque el archivo tenga ACL valida.

3. **Sin entrada ACL especifica, manda `group::`/`other::`**
   ```bash
   sudo touch /srv/base.txt
   sudo chown root:grupo_datos /srv/base.txt
   sudo chmod 640 /srv/base.txt
   getfacl /srv/base.txt
   ```
   Resultado esperado:
   - Si `alumno1` no es dueño ni tiene entrada `user:alumno1:*`, su acceso dependera de si entra por grupo (`group::`) o por otros (`other::`).

Nota didactica:
- Los casos de Samba y NFS se tratan despues, en la seccion de integracion, cuando ya se han explicado ambos servicios.

### Checkpoint (antes de Samba/NFS)
- Hay que recordar solo 3 ideas:

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

### Ejemplo guiado en Ubuntu (escenario guion de clase)
1. Si no tienes LDAP, prepara usuarios/grupo locales:
   ```bash
   sudo groupadd grupo_datos
   sudo useradd -m -G grupo_datos profesor
   sudo useradd -m -G grupo_datos alumno1
   ```
2. Crea el recurso y aplica permisos base:
   ```bash
   sudo mkdir -p /srv/aso-ud4/compartida
   sudo chown root:grupo_datos /srv/aso-ud4/compartida
   sudo chmod 2770 /srv/aso-ud4/compartida   # setgid para heredar grupo
   ```
3. Añade ACL (explícitas y por defecto):
   ```bash
   sudo setfacl -R -m g:grupo_datos:rwX -m u:profesor:rwX -m u:alumno1:rwX /srv/aso-ud4/compartida
   sudo setfacl -R -m d:g:grupo_datos:rwX -m d:u:profesor:rwX -m d:u:alumno1:rwX /srv/aso-ud4/compartida
   ```
4. Comprueba la máscara (si ves permisos recortados, ajusta):
   ```bash
   getfacl /srv/aso-ud4/compartida
   sudo setfacl -m m::rwx /srv/aso-ud4/compartida   # opcional si la mask quedo baja
   ```
5. Valida herencia y acceso:
   ```bash
   sudo -u alumno1 touch /srv/aso-ud4/compartida/ok-alumno1   # debe crear
   sudo -u profesor touch /srv/aso-ud4/compartida/ok-profesor # debe crear
   ```
6. Revisión final:
   ```bash
   ls -ld /srv/aso-ud4/compartida       # debe mostrar g+s y "+"
   getfacl /srv/aso-ud4/compartida
   ```
7. Limpieza opcional: `sudo setfacl -bR /srv/aso-ud4/compartida` (vuelve al modo POSIX clasico).

## 5. Notas de integración (ACL, Samba y NFS)
- Escenario de referencia en esta seccion: **guion de clase** (`ud4-lab` / `ud4-client`, recurso `/srv/aso-ud4/compartida`).
- En integracion real hay **tres capas** que deben permitir a la vez:
  1. **Identidad** (LDAP/SSSD): quien es el usuario y a que grupos pertenece.
  2. **Servicio** (Samba o NFS): quien puede entrar al recurso compartido.
  3. **Sistema de ficheros** (POSIX + ACL): que puede hacer dentro (leer/escribir/entrar).
- Si una capa deniega, el acceso final se deniega.

### 5.1 Capa de sistema de ficheros (POSIX + ACL)
- **ACL POSIX** amplian `ugo`; la entrada `mask` limita permisos efectivos de grupos y usuarios ACL adicionales.
- **Default ACL** define herencia en lo nuevo; sin default ACL, herencia depende de modo POSIX + `umask`.
- **`umask`** recorta al crear. Con `umask 077`, un archivo nuevo tiende a nacer cerrado para grupo/otros salvo que default ACL abra permisos.
- En escritura sobre archivos dentro de directorios recuerda:
  - necesitas permisos sobre el archivo, y
  - necesitas `x` (travesia) y normalmente `w` sobre el directorio.

Comprobaciones utiles:
```bash
namei -l /srv/aso-ud4/compartida/fichero.txt   # revisa permisos por cada tramo del path
getfacl /srv/aso-ud4/compartida/fichero.txt    # revisa ACL y mask efectiva
id alumno1                              # revisa grupos efectivos
```

### 5.2 Capa Samba (SMB/CIFS)
- **Samba** es el servicio que implementa **SMB/CIFS** en Linux/Unix para compartir carpetas e impresoras en red (especialmente con clientes Windows).
- En practica, Samba publica el recurso compartido y aplica reglas de acceso al share; despues el sistema de ficheros Linux decide el permiso final sobre cada operacion.
- Orden real de evaluacion (que se comprueba primero):
  1. **Autenticacion SMB**: usuario/contrasena validos.
  2. **Reglas del share en Samba**: `valid users`, `read only`, `write list`, etc.  
     Si falla aqui, no entras al recurso.
  3. **Permisos del sistema de ficheros (POSIX + ACL)** en el servidor: kernel Linux, `mask`, ACL y permisos de travesia del path.  
     Si falla aqui, entras al recurso pero operaciones como `put`/`mkdir` devuelven "Access denied".
- Resumen: Samba controla la **puerta de entrada**; el FS controla la **operacion final** sobre ficheros y directorios.
- Parametros clave para este laboratorio:
  - `vfs objects = acl_xattr`: conserva ACL compatibles con clientes SMB.
  - `inherit permissions = yes`: ayuda a heredar permisos del directorio padre.
  - `create mask` y `directory mask`: maximos de permisos que Samba crea; si son muy restrictivos, recortan lo que esperabas por ACL.

Diagnostico rapido Samba:
```bash
# servidor (ud4-lab)
testparm -s
sudo tail -n 50 /var/log/samba/log.smbd

# cliente (ud4-client)
smbclient //ud4-lab/compartida -U alumno1
# dentro: put /etc/hosts prueba.txt
```

### 5.3 Capa NFS
- **NFS** (Network File System) permite montar en red un directorio remoto como si fuera local.
- Orden real de evaluacion en NFS (que se comprueba primero):
  1. El cliente monta una exportacion publicada por el servidor (`/etc/exports`).
  2. El servidor identifica al usuario segun el modo de seguridad (`sec=sys` usa UID/GID numericos).
  3. El kernel del servidor aplica permisos POSIX/ACL del directorio/archivo exportado.
- Consecuencia clave: en NFS no decide el cliente; decide siempre el servidor sobre su FS.
- Si cliente y servidor no mapean igual UID/GID en `sec=sys`, obtendras "Permission denied" aunque el nombre de usuario coincida.
- `root_squash` evita que root del cliente sea root en servidor (buena practica).
- NFSv4 puede usar ACL nativas diferentes a POSIX ACL; en este laboratorio se prioriza comportamiento uniforme con ACL POSIX.

Diagnostico rapido NFS:
```bash
# servidor (donde se exporta la ruta)
exportfs -v

# cliente (donde montas la ruta remota)
showmount -e ud4-lab
mount | grep nfs

# comprobar identidad en ambos lados (servidor y cliente)
id alumno1
getent passwd alumno1
```

### 5.4 Orden mental para depurar un "Permission denied"
1. **Identidad**: `id usuario`, `getent passwd usuario`, `getent group grupo_datos`.
2. **Servicio**:
   - Samba: revisar `valid users`, `read only`, masks, `testparm`.
   - NFS: revisar export (`exportfs -v`) y tipo de seguridad (`sec=sys`/Kerberos).
3. **FS**: revisar `ls -ld`, `getfacl`, `mask`, `default ACL`, y permisos de travesia en todo el path.
4. **Prueba minima reproducible**: crear un archivo con el usuario real (`sudo -u usuario touch ...`) y repetir desde cliente.

### 5.5 Errores tipicos de laboratorio
- ACL correcta en archivo, pero directorio sin `x` para ese usuario/grupo.
- ACL `rwX` configurada, pero `mask::r--` recorta escritura.
- Usuario permitido en Samba, pero no existe/mapea distinto en el host (`getent` falla).
- `create mask` de Samba demasiado baja (por ejemplo `0640`) y rompe colaboracion.
- En NFS, UID/GID distintos entre cliente y servidor aunque el nombre de usuario coincida.

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
# servidor NFS
sudo apt install nfs-kernel-server

# cliente NFS
sudo apt install nfs-common
```
### 2.2 Exportación y opciones clave
- El FS debe soportar ACL POSIX si quieres herencia/permisos granulares.
- En el **servidor NFS** (`10.50.0.11`), `/etc/exports` ejemplo:
  ```
  /srv/grupo_clase 10.50.0.0/24(rw,sync,subtree_check,acl,root_squash,fsid=0)
  /home/usuarios  10.50.0.0/24(rw,sync,subtree_check,acl,root_squash)
  ```
  - Activar cambios y comprobar:
    - `sudo exportfs -ra`
    - `sudo exportfs -v`
  - `root_squash`: root del cliente no es root en servidor.
  - `acl`: exporta respetando ACL POSIX.
  - `fsid=0`: pseudo-root para NFSv4.
### 2.3 Cliente y montaje automático
- En el **cliente NFS**:
  - Manual: `mount -t nfs 10.50.0.11:/srv/grupo_clase /mnt/comp`.
  - `/etc/fstab`: `10.50.0.11:/srv/grupo_clase /mnt/comp nfs defaults,_netdev 0 0`.
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

[grupo_clase]
  path = /srv/grupo_clase
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
- Resolución de nombres: evita `wins`; usa DNS o IP directa. Prueba con `smbclient -L //10.50.0.11 -U usuario`.
- Perfiles/Homes: la sección `[homes]` sirve directorios personales con 0700. Si usas perfiles móviles, ajusta cuotas y paths UNC (`\\10.50.0.11\homes`).

### 3.3 Puesta en marcha y pruebas rapidas
- Instala servidor y cliente: `sudo apt install samba samba-client` (en RHEL/Fedora: `dnf -y install samba samba-client`).
- Servicio: `sudo systemctl enable --now smbd nmbd` (activa NetBIOS para entornos mixtos); revisa sintaxis con `testparm`.
- Usuarios Samba: crea credencial local con `sudo pdbedit -a usuario` (o `smbpasswd -a`); deben existir en el sistema/LDAP.
- Pruebas desde cliente (o desde cualquier host con red al servidor): `smbclient -L //10.50.0.11 -U usuario` para ver compartidos y `smbclient //10.50.0.11/grupo_clase -U usuario` para verificar acceso.
- Para limitar superficie, en `[global]` añade `interfaces = lo eth0` y, si procede, `bind interfaces only = yes`.


## 4. Nextcloud
- Plataforma de ficheros colaborativos (WebDAV) con apps móviles y web.
- Instalación rápida (Ubuntu): `sudo snap install nextcloud` o stack LAMP+PHP-FPM.
- Permisos de ficheros: datos bajo `data/`, dueño `www-data`, `chmod 750`.
- Autenticación LDAP: app "LDAP user and group backend", usa la CA de tu lab TLS.
- Almacenamiento externo: apunta a rutas locales o montadas (NFS/SMB). Las ACL del FS mandan; Nextcloud controla comparticiones lógicas encima.
