---
search:
  exclude: true
---

# ✅ Soluciones guía – ACL en sistemas de ficheros

## 1. Soporte ACL
- `mount | grep ext4` → opciones incluyen `rw,relatime,acl` (ok).  
- Si falta: `mount -o remount,acl /` y repetir el `mount`.

## 2. Lectura de ACL
```bash
mkdir ~/demo-acl && touch ~/demo-acl/a ~/demo-acl/b
getfacl ~/demo-acl
```
Salida típica muestra `# file: demo-acl`, entradas `user::rwx`, `group::r-x`, `mask::rwx`, `other::r-x`. La **mask** limita los permisos efectivos de todas las entradas adicionales.

## 3. Proyecto compartido
```bash
sudo mkdir -p /srv/proyecto
sudo chown root:proyecto /srv/proyecto
sudo chmod 2770 /srv/proyecto
sudo setfacl -R -m g:equipo:rwX -m u:luis:rwX -m u:ana:rX /srv/proyecto
sudo setfacl -R -m d:g:equipo:rwX -m d:u:luis:rwX -m d:u:ana:rX /srv/proyecto
sudo -u luis touch /srv/proyecto/ok-luis
sudo -u ana  touch /srv/proyecto/ok-ana  # debe fallar en escritura
```
`getfacl /srv/proyecto` debe mostrar entradas `user:luis`, `user:ana`, `group:equipo` y sus versiones `default`.

## 4. Limpieza
```bash
sudo setfacl -bR /srv/proyecto
sudo getfacl /srv/proyecto   # solo user/group/other
```

## 5. Samba o NFS
- Samba: comparte `path = /srv/proyecto` con `inherit permissions = yes`.  
  Desde cliente, `touch` como usuario del grupo `equipo` funciona; fuera del grupo falla con “Permiso denegado”.
- NFS: exporta con `/srv/proyecto 192.168.56.0/24(rw,fsid=0,acl)` y monta en cliente. `touch` respeta la ACL POSIX del servidor.

## 6. Auditoría rápida
```bash
#!/usr/bin/env bash
LOG=/var/log/acl-audit-$(date +%F).log
find /srv -maxdepth 2 -type d -printf "%M %p\n" | awk '/\\+$/{print $2}' | while read d; do
  {
    echo "### $d"
    getfacl "$d"
  } >> "$LOG"
done
```

## 7. Reto Ansible (ejemplo mínimo)
`inventory.yml`
```yaml
all:
  hosts:
    r1: {ansible_network_os: cisco.ios.ios, ansible_host: 10.0.0.1}
    r2: {ansible_network_os: cisco.ios.ios, ansible_host: 10.0.0.2}
  vars:
    ansible_connection: network_cli
```
`playbook.yml`
```yaml
- hosts: all
  gather_facts: no
  vars:
    acl_name: INTRANET
    acl_rules:
      - {seq: 10, line: "permit tcp 10.10.0.0 0.0.255.255 any eq 443"}
      - {seq: 20, line: "deny ip any any log"}
  tasks:
    - name: Deploy ACL
      ios_config:
        lines: "{{ acl_rules | map('json_query', 'line') | list }}"
        parents: "ip access-list extended {{ acl_name }}"
    - name: Validate ACL
      ios_command:
        commands: ["show ip access-lists {{ acl_name }}"]
      register: show_acl
    - debug: var=show_acl.stdout_lines
```
Ejecuta con `ansible-playbook -i inventory.yml playbook.yml` y captura la salida de `show ip access-lists`.

---

# 🧪 Solución guía – Laboratorio integrado (LDAP Docker + Fileserver LXD con ACL, NFS/Samba)

Pasos base (ajusta IP/domino según tu despliegue):

> Nota de red: LDAP está en Docker. Asegura que el contenedor expone 389/636 al host (`ports:` en compose) y que desde LXD puedes llegar al IP del host (`ping <IP_host>`, `nc -vz <IP_host> 636`). Si usas `ufw`, abre 636/389 al segmento de `lxdbr0`.

1. **Fileserver en LXD**  
   ```bash
   # Si falla "imagen no encontrada", usa el remoto ubuntu en lugar de images
   # lxc image list ubuntu: | head   # para ver alias disponibles
   lxc launch ubuntu:22.04 filesrv --config security.nesting=true
   lxc exec filesrv -- bash
   apt update && apt install -y sssd-ldap libpam-sss libnss-sss ldap-utils acl
   cat >/etc/sssd/sssd.conf <<'EOF'
   [sssd]
   services = nss, pam
   domains = ldap

   [domain/ldap]
   id_provider = ldap
   auth_provider = ldap
   ldap_uri = ldaps://<IP_HOST_O_BRIDGE_DOCKER>:636
   ldap_search_base = dc=empresa,dc=com
   ldap_tls_cacert = /etc/ssl/certs/ca-ldap.crt
   cache_credentials = true
   EOF
   chmod 600 /etc/sssd/sssd.conf
   cp /ruta/a/ca-ldap.crt /etc/ssl/certs/
   update-ca-certificates
   systemctl enable --now sssd
   ```
   PAM: añade en `/etc/pam.d/common-session` la línea `session required pam_mkhomedir.so skel=/etc/skel umask=077`.  
   NSS: asegúrate de tener `sss` en `passwd`, `group`, `shadow` en `/etc/nsswitch.conf`.  
   Verifica resolución: `getent passwd alumno1`.

2. **Homes y compartida con ACL**  
   ```bash
   mkdir -p /home/usuarios
   chown root:root /home/usuarios
   chmod 755 /home/usuarios

   mkdir -p /srv/compartida
   chown root:equipo /srv/compartida   # grupo 'equipo' viene de LDAP
   chmod 2770 /srv/compartida
   setfacl -m g:equipo:rwX /srv/compartida
   setfacl -m d:g:equipo:rwX /srv/compartida
   ```
   Pruebas:
   ```bash
   su - alumno1                           # crea /home/usuarios/alumno1 700
   sudo -u alumno1 touch /srv/compartida/ok-alumno1   # OK si en grupo
   sudo -u usuariofuera touch /srv/compartida/fallo   # Permiso denegado
   getfacl /srv/compartida
   ```

3. **Exportación NFS**  
   ```bash
   apt install -y nfs-kernel-server
   cat >>/etc/exports <<'EOF'
   /srv/compartida 10.0.0.0/24(rw,sync,subtree_check,acl,root_squash,fsid=0)
   /home/usuarios  10.0.0.0/24(rw,sync,subtree_check,acl,root_squash)
   EOF
   exportfs -ra
   systemctl restart nfs-kernel-server
   ```
   Cliente: `mount -t nfs filesrv:/srv/compartida /mnt/comp` y prueba `touch` con usuario miembro/no miembro.

4. **Compartición Samba (alternativa u opcional)**  
   ```bash
   apt install -y samba
   cat >>/etc/samba/smb.conf <<'EOF'
[global]
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
EOF
   testparm
   systemctl restart smbd
   ```
   Cliente: `smbclient //filesrv/compartida -U alumno1 -c "put /etc/hostname ok"` (debe funcionar si es del grupo); usuario fuera del grupo debe fallar al escribir.

5. **Comprobación TLS de LDAP**  
   ```bash
   openssl s_client -connect <IP_LDAP>:636 -CAfile /etc/ssl/certs/ca-ldap.crt -verify_return_error
   ldapsearch -H ldaps://<IP_LDAP> -D "cn=admin,dc=empresa,dc=com" -W -b dc=empresa,dc=com -x -LLL "(uid=alumno1)"
   ```

6. **Entrega típica**  
   - Salida de `getent passwd alumno1`, `getfacl /srv/compartida`.  
   - Capturas de prueba de escritura permitida/denegada en compartida.  
   - Montaje NFS o acceso Samba mostrando respeto de ACL.  
   - Comprobación TLS (`openssl s_client`) y búsqueda LDAP (`ldapsearch`).
