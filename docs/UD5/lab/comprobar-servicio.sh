#!/usr/bin/env bash
# Uso: comprobar-servicio.sh UNIDAD.service DIRECTORIO_ESTADO
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
umask 077
[[ $# -eq 2 && $1 =~ ^[a-zA-Z0-9_.@-]+\.service$ && $1 != -* && $2 = /* && -d $2 && -w $2 ]] || {
    echo 'Uso: comprobar-servicio.sh UNIDAD.service DIRECTORIO_ABSOLUTO_ESCRIBIBLE' >&2; exit 2;
}
unidad=$1
destino=$2
exec 9>"$destino/.servicio.lock"
flock -n -E 75 9 || { echo 'Comprobación ya en ejecución' >&2; exit 75; }
if systemctl is-active --quiet "$unidad"; then
    rm -f -- "$destino/$unidad.incidencia"
    echo "$(date --iso-8601=seconds) OK $unidad"
else
    printf '%s INACTIVO O NO DISPONIBLE %s\n' "$(date --iso-8601=seconds)" "$unidad" >"$destino/$unidad.incidencia"
    cat -- "$destino/$unidad.incidencia" >&2
    exit 1
fi
