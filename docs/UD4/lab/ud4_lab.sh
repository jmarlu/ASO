#!/usr/bin/env bash
set -euo pipefail

CONTAINER_SERVER="ud4-lab"
CONTAINER_CLIENT="ud4-client"
IMAGE="ubuntu:24.04"
LAB_ROOT="/srv/aso-ud4"
GROUP="grupo_datos"
USER_PROF="profesor"
USER_ALU="alumno1"

usage() {
  cat <<'USAGE'
Uso: ./ud4_lab.sh [setup|setup-client|demo-acl|cleanup|shell|shell-client]

setup:     crea el contenedor servidor y prepara el laboratorio dentro
setup-client: crea un contenedor cliente para probar SMB/NFS
 demo-acl: aplica ACL y valida herencia dentro del contenedor
cleanup:   elimina los contenedores del laboratorio
 shell:    abre una shell en el contenedor servidor
 shell-client: abre una shell en el contenedor cliente
USAGE
}

ensure_lxd() {
  if ! command -v lxc >/dev/null 2>&1; then
    echo "ERROR: 'lxc' no esta instalado. Instala LXD y vuelve a intentar."
    exit 1
  fi
  if ! lxc info >/dev/null 2>&1; then
    echo "ERROR: LXD no esta inicializado. Ejecuta 'sudo lxd init' y vuelve a intentar."
    exit 1
  fi
}

container_exists() {
  lxc list -c n --format csv | grep -qx "$1"
}

setup() {
  ensure_lxd
  if container_exists "$CONTAINER_SERVER"; then
    lxc start "$CONTAINER_SERVER" >/dev/null 2>&1 || true
  else
    lxc launch "$IMAGE" "$CONTAINER_SERVER"
  fi

  lxc exec "$CONTAINER_SERVER" -- apt-get update -y
  lxc exec "$CONTAINER_SERVER" -- apt-get install -y acl samba samba-common-bin nfs-kernel-server nfs-common snapd curl sudo
  lxc exec "$CONTAINER_SERVER" -- systemctl enable --now smbd nmbd nfs-kernel-server snapd

  lxc exec "$CONTAINER_SERVER" -- bash -c "groupadd -f '$GROUP'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "id -u '$USER_PROF' >/dev/null 2>&1 || useradd -m -G '$GROUP' '$USER_PROF'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "id -u '$USER_ALU' >/dev/null 2>&1 || useradd -m -G '$GROUP' '$USER_ALU'"

  lxc exec "$CONTAINER_SERVER" -- bash -c "mkdir -p '$LAB_ROOT/compartida'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "chown root:'$GROUP' '$LAB_ROOT/compartida'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "chmod 2770 '$LAB_ROOT/compartida'"

  echo "Servidor preparado en '$CONTAINER_SERVER' con recursos en $LAB_ROOT"
}

demo_acl() {
  ensure_lxd
  if ! container_exists "$CONTAINER_SERVER"; then
    echo "ERROR: el contenedor '$CONTAINER_SERVER' no existe. Ejecuta './ud4_lab.sh setup' primero."
    exit 1
  fi

  lxc exec "$CONTAINER_SERVER" -- bash -c "setfacl -R -m g:'$GROUP':rwX -m u:'$USER_PROF':rwX -m u:'$USER_ALU':rwX '$LAB_ROOT/compartida'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "setfacl -R -m d:g:'$GROUP':rwX -m d:u:'$USER_PROF':rwX -m d:u:'$USER_ALU':rwX '$LAB_ROOT/compartida'"

  echo "ACL aplicadas. Prueba rapida dentro del contenedor:"
  lxc exec "$CONTAINER_SERVER" -- bash -c "sudo -u '$USER_ALU' touch '$LAB_ROOT/compartida/ok-alumno1'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "sudo -u '$USER_PROF' touch '$LAB_ROOT/compartida/ok-profesor'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "ls -ld '$LAB_ROOT/compartida'"
  lxc exec "$CONTAINER_SERVER" -- bash -c "getfacl '$LAB_ROOT/compartida' | head -n 25"
}

setup_client() {
  ensure_lxd
  if container_exists "$CONTAINER_CLIENT"; then
    lxc start "$CONTAINER_CLIENT" >/dev/null 2>&1 || true
  else
    lxc launch "$IMAGE" "$CONTAINER_CLIENT"
  fi

  lxc exec "$CONTAINER_CLIENT" -- apt-get update -y
  lxc exec "$CONTAINER_CLIENT" -- apt-get install -y nfs-common samba-client cifs-utils curl
  echo "Cliente preparado en '$CONTAINER_CLIENT'"
}

cleanup() {
  ensure_lxd
  if container_exists "$CONTAINER_SERVER"; then
    lxc delete -f "$CONTAINER_SERVER"
  fi
  if container_exists "$CONTAINER_CLIENT"; then
    lxc delete -f "$CONTAINER_CLIENT"
  fi
  echo "Contenedores eliminados."
}

shell() {
  ensure_lxd
  if ! container_exists "$CONTAINER_SERVER"; then
    echo "ERROR: el contenedor '$CONTAINER_SERVER' no existe. Ejecuta './ud4_lab.sh setup' primero."
    exit 1
  fi
  lxc exec "$CONTAINER_SERVER" -- bash
}

shell_client() {
  ensure_lxd
  if ! container_exists "$CONTAINER_CLIENT"; then
    echo "ERROR: el contenedor '$CONTAINER_CLIENT' no existe. Ejecuta './ud4_lab.sh setup-client' primero."
    exit 1
  fi
  lxc exec "$CONTAINER_CLIENT" -- bash
}

case "${1:-}" in
  setup) setup ;;
  setup-client) setup_client ;;
  demo-acl) demo_acl ;;
  cleanup) cleanup ;;
  shell) shell ;;
  shell-client) shell_client ;;
  *) usage; exit 1 ;;
esac
