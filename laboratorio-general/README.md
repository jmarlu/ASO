# Laboratorio general (LDAP + Vagrant + LXC Samba)

Laboratorio autocontenido para practicar identidad centralizada con LDAP y servicios que la consumen:
- **Docker (OpenLDAP con StartTLS)** con usuarios `profesor` (sudo) y `alumno1`.
- **Vagrant (Ubuntu con entorno gráfico)** autenticando contra ese LDAP y creando el *home* al iniciar sesión.
- **Contenedor LXC con Samba** que usa el mismo LDAP; cada usuario tiene su carpeta privada y una compartida por grupo, con `profesor` pudiendo entrar a las carpetas de los alumnos.

Supuestos comunes (personaliza en los ficheros si cambias algo):
- Dominio/base LDAP: `dc=laboratorio,dc=local`
- Admin LDAP: `cn=admin,dc=laboratorio,dc=local` con contraseña `admin`
- Red privada VirtualBox: `10.50.0.0/24`
- VM-SERVIDOR: `10.50.0.10` (LDAP en Docker `:389`, Samba LXD `10.50.0.11`)
- VM-CLIENTE: `10.50.0.20` (GUI y login contra LDAP)
- Credenciales iniciales:  
  - `profesor` / `Profesor123` (pertenece a `profesores`, sudo en la VM)  
  - `alumno1` / `Alumno123` (pertenece a `alumnos`)  

## 1) LDAP en Docker (con StartTLS)
Ruta: `laboratorio-general/ldap/`

El LDAP se levanta dentro de la **VM-SERVIDOR** (Vagrant lo arranca en el provisioning).
Si necesitas relanzarlo manualmente:

```bash
vagrant up servidor
vagrant ssh servidor
cd /srv/hostshare/ldap
docker compose up -d     # levanta OpenLDAP y carga el LDIF con base+usuarios+grupos
```

- Expone `ldap://0.0.0.0:389` → úsalo como `ldap://10.50.0.10:389` desde la VM y el contenedor LXC.
- StartTLS está habilitado con certificados locales en `laboratorio-general/ldap/certs`. Para recrear el LDAP con TLS, usa `docker compose down -v` antes de `up -d`.
- Los ficheros LDIF crean unidades organizativas, grupos (`profesores`, `alumnos`, `grupo_datos`) y usuarios con atributos `posixAccount`. Las contraseñas están en texto claro para simplificar la demo.

## 2) VM Ubuntu con GUI y login LDAP
Ruta: `laboratorio-general/vagrant/`

```bash
cd laboratorio-general/vagrant
vagrant up servidor
vagrant up cliente
```

- Vagrant levanta dos VMs: `servidor` (`10.50.0.10`) y `cliente` (`10.50.0.20`).
- Box: Ubuntu LTS con red privada `10.50.0.20` en el cliente (ajusta en `Vagrantfile` si te choca con otra red).
- Provisioning:
  - Instala un escritorio ligero (XFCE) y herramientas LDAP.
  - Configura SSSD (NSS/PAM) para autenticación contra el LDAP publicado en el host (`LDAP_HOST` configurable) usando StartTLS.
  - Activa `pam_mkhomedir` para crear `/home/<usuario>` al iniciar sesión.
  - Da sudo al grupo `profesores` (por lo tanto `profesor` puede usar `sudo`).

## 3) Contenedor LXC con Samba + LDAP
Ruta: `laboratorio-general/lxc-samba/` (se ejecuta dentro de la **VM-SERVIDOR**)

Pasos orientativos (LXD en modo bridge sobre `enp0s8` para IP `10.50.0.11`):
```bash
# 3.1 (VM-SERVIDOR) Convertir eth1 en bridge br0 con IP 10.50.0.10
sudo tee /etc/netplan/01-br0.yaml <<'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      dhcp4: no
  bridges:
    br0:
      interfaces: [enp0s8]
      addresses: [10.50.0.10/24]
EOF
sudo netplan apply

# 3.2 Inicializar LXD (usa lxdbr0 NAT para Internet)
sudo lxd init --auto

# 3.3 Crear contenedor LXD y añadir NIC bridged al lab
lxc init ubuntu:22.04 samba-lab
lxc config device add samba-lab eth1 nic nictype=bridged parent=br0
lxc start samba-lab

# 3.4 IP fija 10.50.0.11 en el contenedor (eth1)
lxc exec samba-lab -- sh -c "cat > /etc/netplan/50-eth1.yaml <<'EOF'
network:
  version: 2
  ethernets:
    eth1:
      dhcp4: no
      addresses: [10.50.0.11/24]
EOF
netplan apply"

# 3.5 Subir los ficheros y provisionar
lxc file push laboratorio-general/lxc-samba/provision.sh samba-lab/root/
lxc file push laboratorio-general/lxc-samba/smb.conf.template samba-lab/root/
lxc exec samba-lab -- bash /root/provision.sh
```

Qué hace el provisioning:
- Instala `samba`, SSSD y utilidades LDAP.
- Instala `acl` para poder usar `getfacl/setfacl` en el contenedor.
- Apunta SSSD y Samba al LDAP de la VM-SERVIDOR (`LDAP_HOST` por defecto `10.50.0.10`; cambia la variable si usas otra red).
- Ejecuta `smbpasswd -w <admin>` para guardar la clave de `cn=admin` y añade las credenciales Samba de `profesor` y `alumno1` (`smbpasswd -a`).
- Crea `/srv/home/<usuario>` con ACL para que `profesor` pueda entrar en los homes de los alumnos.
- Crea `/srv/grupo_clase` con ACL para `alumnos` y `profesores`.
- Comparte `[homes]` (privados) y `[grupo_clase]` en Samba.

Requisito ACL en el host:
- El contenedor LXD hereda el soporte ACL del sistema de ficheros del host. Comprueba en la VM-SERVIDOR:
  - `mount | grep \" / \"` (debe incluir `acl` o venir activo por defecto)
  - `tune2fs -l /dev/sdXN | grep acl`

## Validaciones rápidas
- Desde la VM-CLIENTE: `id profesor`, `id alumno1`, `getent passwd profesor`, `getent group profesores`.
- En la VM-CLIENTE: iniciar sesión gráfica con `profesor` y `alumno1` → deben generarse `/home/profesor` y `/home/alumno1`.
- En el contenedor Samba (`lxc exec samba-lab -- bash`):
  - `getent passwd profesor`
  - `smbclient -L localhost -U profesor`
  - `smbclient //localhost/grupo_clase -U alumno1` (debe acceder; prueba escribir y ver que `profesor` puede leer).

## Cómo ajustar host/IP/contraseñas
- Cambia el host/IP en `laboratorio-general/vagrant/Vagrantfile` (`LDAP_HOST` + IPs de VMs) y en `laboratorio-general/lxc-samba/provision.sh`.
- Cambia contraseñas de LDAP en `laboratorio-general/ldap/bootstrap.ldif` y refresca el contenedor (`docker compose down -v && docker compose up -d`).
- Si cambias la clave de `cn=admin`, recuerda actualizar `LDAP_ADMIN_PASSWORD` en la VM y ejecutar `smbpasswd -w` con el nuevo valor dentro del contenedor Samba.
