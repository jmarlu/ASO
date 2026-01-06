#!/usr/bin/env bash
set -euo pipefail

LDAP_HOST=${LDAP_HOST:-10.50.0.10}
LDAP_PORT=${LDAP_PORT:-389}
LDAP_BASE=${LDAP_BASE:-dc=laboratorio,dc=local}
LDAP_BINDDN=${LDAP_BINDDN:-cn=admin,dc=laboratorio,dc=local}
LDAP_BINDPW=${LDAP_BINDPW:-admin}
PROF_PASS=${PROF_PASS:-Profesor123}
ALUM_PASS=${ALUM_PASS:-Alumno123}

export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Instalando dependencias Samba + LDAP (servidor LDAP en ${LDAP_HOST}:${LDAP_PORT})"
apt-get update
apt-get install -y samba smbclient \
  sssd sssd-ldap sssd-tools libnss-sss libpam-sss ldap-utils acl gettext-base

cat >/usr/local/sbin/samba-mkhomedir.sh <<'EOF'
#!/usr/bin/env bash
user="$1"
home="/srv/home/${user}"

# Crea home si no existe cuando el usuario accede por Samba
if [ -d "$home" ]; then
  exit 0
fi

if getent passwd "$user" >/dev/null; then
  primary_group="$(id -gn "$user" 2>/dev/null || true)"
  mkdir -p "$home"
  if [ -n "$primary_group" ]; then
    chown "$user":"$primary_group" "$home" || true
  else
    chown "$user":"$user" "$home" || true
  fi
  chmod 700 "$home"
  if [ "$user" != "profesor" ]; then
    setfacl -m u:profesor:rwx "$home" || true
    setfacl -m d:u:profesor:rwx "$home" || true
  fi
fi
EOF
chmod +x /usr/local/sbin/samba-mkhomedir.sh

mkdir -p /etc/ldap
cat >/etc/ldap/ldap.conf <<EOF
BASE ${LDAP_BASE}
URI ldap://${LDAP_HOST}:${LDAP_PORT}
TLS_REQCERT never
EOF

cat >/etc/sssd/sssd.conf <<EOF
[sssd]
services = nss, pam
config_file_version = 2
domains = LDAP

[domain/LDAP]
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
ldap_uri = ldap://${LDAP_HOST}:${LDAP_PORT}
ldap_search_base = ${LDAP_BASE}
ldap_default_bind_dn = ${LDAP_BINDDN}
ldap_default_authtok = ${LDAP_BINDPW}
ldap_tls_reqcert = never
cache_credentials = true
enumerate = false
ldap_id_use_start_tls = true
ldap_referrals = false
fallback_homedir = /srv/home/%u
EOF
chmod 600 /etc/sssd/sssd.conf

sed -i 's/^passwd:.*/passwd:         files systemd sss/' /etc/nsswitch.conf
sed -i 's/^group:.*/group:          files systemd sss/' /etc/nsswitch.conf
sed -i 's/^shadow:.*/shadow:         files sss/' /etc/nsswitch.conf

systemctl enable --now sssd.service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LDAP_HOST LDAP_PORT LDAP_BASE LDAP_BINDDN

# Render de plantilla de Samba
envsubst '$LDAP_HOST $LDAP_PORT $LDAP_BASE $LDAP_BINDDN' < "${SCRIPT_DIR}/smb.conf.template" > /etc/samba/smb.conf

# Guarda la clave de admin LDAP en secrets.tdb para poder usar ldapsam
smbpasswd -w "${LDAP_BINDPW}"

echo "[INFO] Creando cuentas Samba (se añaden atributos samba* en LDAP)"
printf "%s\n%s\n" "${PROF_PASS}" "${PROF_PASS}" | smbpasswd -a profesor
printf "%s\n%s\n" "${ALUM_PASS}" "${ALUM_PASS}" | smbpasswd -a alumno1

mkdir -p /srv/home /srv/grupo_clase

for u in profesor alumno1; do
  if getent passwd "$u" >/dev/null; then
    HOME_DIR="/srv/home/${u}"
    mkdir -p "${HOME_DIR}"
    primary_group="$(id -gn "$u")"
    chown "$u":"${primary_group}" "${HOME_DIR}" || true
    chmod 700 "${HOME_DIR}"
    # Profesor debe poder entrar en homes de alumnos
    if [ "$u" != "profesor" ]; then
      setfacl -m u:profesor:rwx "${HOME_DIR}"
      setfacl -m d:u:profesor:rwx "${HOME_DIR}"
    fi
  else
    echo "[WARN] No se pudo resolver ${u} en LDAP (¿LDAP levantado?)"
  fi
done

# Carpeta compartida
if getent group grupo_datos >/dev/null; then
  chown root:grupo_datos /srv/grupo_clase
else
  chown root:root /srv/grupo_clase
fi
chmod 2770 /srv/grupo_clase
setfacl -m g:alumnos:rwx -m g:profesores:rwx /srv/grupo_clase || true
setfacl -m d:g:alumnos:rwx -m d:g:profesores:rwx /srv/grupo_clase || true

systemctl restart smbd.service
systemctl restart nmbd.service || true
systemctl enable smbd.service

echo "[INFO] Samba listo. Comprueba con 'smbclient -L localhost -U profesor'."
