
# 🔐 Autenticación centralizada (Linux PAM + NSS)

## 0) Atributos POSIX en LDAP
- Usuarios: inetOrgPerson + posixAccount (uidNumber, gidNumber, homeDirectory, loginShell)
- Grupos: posixGroup (gidNumber)

## A) SSSD (recomendado)
1. Instalar:
```bash
sudo apt update
sudo apt install -y sssd-ldap libnss-sss libpam-sss
```
2. `/etc/sssd/sssd.conf` (600):
```ini
[sssd]
services = nss, pam
config_file_version = 2
domains = LDAP

[domain/LDAP]
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap

ldap_uri = ldap://<IP_DEL_LDAP>:389
ldap_search_base = dc=asir,dc=local
ldap_default_bind_dn = cn=admin,dc=asir,dc=local
ldap_default_authtok = admin123

ldap_id_use_start_tls = false
ldap_tls_reqcert = allow

ldap_user_object_class = posixAccount
ldap_user_name = uid
ldap_user_uid_number = uidNumber
ldap_user_gid_number = gidNumber
ldap_user_home_directory = homeDirectory
ldap_user_shell = loginShell

ldap_group_object_class = posixGroup
ldap_group_name = cn
ldap_group_gid_number = gidNumber

cache_credentials = True
enumerate = False
```
3. Habilitar:
```bash
sudo systemctl enable --now sssd
```
4. NSS (`/etc/nsswitch.conf`):
```
passwd: files sss
group:  files sss
shadow: files sss
```
5. PAM (`/etc/pam.d/common-session`):
```
session required pam_mkhomedir.so skel=/etc/skel/ umask=0077
```
6. Pruebas:
```bash
getent passwd profesor
getent group asir
sudo su - profesor
```

## B) nslcd (alternativa)
1. Instalar:
```bash
sudo apt install -y libnss-ldapd libpam-ldapd nslcd
```
2. `/etc/nslcd.conf`:
```
uri ldap://<IP_DEL_LDAP>:389
base dc=asir,dc=local
binddn cn=admin,dc=asir,dc=local
bindpw admin123
ssl off
tls_reqcert allow
```
3. NSS (`/etc/nsswitch.conf`):
```
passwd: files systemd ldap
group:  files systemd ldap
shadow: files ldap
```
4. PAM:
```bash
sudo pam-auth-update  # habilita "Create home directory on login"
sudo systemctl enable --now nslcd
```
5. Pruebas:
```bash
getent passwd profesor
sudo su - profesor
```
