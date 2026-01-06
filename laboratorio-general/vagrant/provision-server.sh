#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Preparando VM-SERVIDOR (Docker + LXD)"

sudo apt-get update
sudo apt-get install -y docker.io docker-compose snapd

sudo systemctl enable --now docker

if ! command -v lxd >/dev/null 2>&1; then
  sudo snap install lxd
fi

sudo usermod -aG lxd vagrant

if [ -f /srv/hostshare/ldap/docker-compose.yml ]; then
  echo "[INFO] Levantando LDAP con Docker Compose"
  if sudo docker compose version >/dev/null 2>&1; then
    sudo docker compose -f /srv/hostshare/ldap/docker-compose.yml up -d
  elif command -v docker-compose >/dev/null 2>&1; then
    sudo docker-compose -f /srv/hostshare/ldap/docker-compose.yml up -d
  else
    echo "[WARN] Docker Compose no disponible; instala docker-compose o docker-compose-plugin."
  fi
fi

cat <<'EOF'
[INFO] VM-SERVIDOR lista.
- LDAP: 10.50.0.10:389 (Docker)
- LXD instalado: ejecuta `sudo lxd init` y configura red bridged para 10.50.0.11 antes de crear el contenedor Samba.
EOF
