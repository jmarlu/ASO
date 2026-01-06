#!/usr/bin/env bash
set -euo pipefail

LDAP_HOST=${LDAP_HOST:-10.50.0.10}
LDAP_PORT=${LDAP_PORT:-389}
LDAP_BASE=${LDAP_BASE:-dc=laboratorio,dc=local}
LDAP_BINDDN=${LDAP_BINDDN:-cn=admin,dc=laboratorio,dc=local}
LDAP_BINDPW=${LDAP_BINDPW:-admin}

echo "[INFO] Configurando VM con LDAP host ${LDAP_HOST}:${LDAP_PORT} base ${LDAP_BASE}"
export DEBIAN_FRONTEND=noninteractive

# Evita diálogos de display manager
echo "lightdm shared/default-x-display-manager select lightdm" | sudo debconf-set-selections

sudo apt-get update
sudo apt-get install -y \
  xfce4 lightdm lightdm-gtk-greeter xorg \
  sssd sssd-ldap sssd-tools libnss-sss libpam-sss ldap-utils \
  policykit-1-gnome smbclient cifs-utils

sudo mkdir -p /etc/ldap
sudo tee /etc/ldap/ldap.conf >/dev/null <<EOF
BASE ${LDAP_BASE}
URI ldap://${LDAP_HOST}:${LDAP_PORT}
TLS_REQCERT never
EOF

sudo tee /etc/sssd/sssd.conf >/dev/null <<EOF
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
fallback_homedir = /home/%u
EOF
sudo chmod 600 /etc/sssd/sssd.conf

# Asegura NSS usando SSSD
sudo sed -i 's/^passwd:.*/passwd:         files systemd sss/' /etc/nsswitch.conf
sudo sed -i 's/^group:.*/group:          files systemd sss/' /etc/nsswitch.conf
sudo sed -i 's/^shadow:.*/shadow:         files sss/' /etc/nsswitch.conf
sudo pam-auth-update --package --force >/dev/null

# Crea homedir al iniciar sesión
if ! grep -q pam_mkhomedir.so /etc/pam.d/common-session; then
  echo "session required        pam_mkhomedir.so skel=/etc/skel/ umask=0022" | sudo tee -a /etc/pam.d/common-session
fi

# Sudo para profesores
echo "%profesores ALL=(ALL:ALL) ALL" | sudo tee /etc/sudoers.d/ldap-profesores >/dev/null
sudo chmod 440 /etc/sudoers.d/ldap-profesores

sudo systemctl enable --now sssd.service
sudo systemctl enable --now lightdm.service

echo "[INFO] Provisioning completado. Prueba con 'id profesor' y 'id alumno1'."
