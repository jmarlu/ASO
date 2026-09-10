#!/usr/bin/env bash
# Uso: informe.sh DIRECTORIO_DESTINO. No necesita root.
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
umask 077
[[ $# -eq 1 && $1 = /* && -d $1 && -w $1 ]] || {
    echo 'Uso: informe.sh DIRECTORIO_ABSOLUTO_EXISTENTE_Y_ESCRIBIBLE' >&2; exit 2;
}
destino=$1
exec 9>"$destino/.informe.lock"
flock -n -E 75 9 || { echo 'Informe ya en ejecución' >&2; exit 75; }
temporal=$(mktemp "$destino/.informe.XXXXXX")
trap 'rm -f -- "$temporal"' EXIT
{
    date --iso-8601=seconds
    printf '\nEquipo: '; hostname
    printf '\nTiempo de actividad y carga:\n'; uptime
    printf '\nDisco:\n'; df -h /
    printf '\nMemoria:\n'; free -h
    printf '\nServicios fallidos:\n'
    systemctl --failed --no-pager || printf 'AVISO: no se pudo consultar systemd\n'
    printf '\nErrores recientes visibles para esta cuenta:\n'
    journalctl -p err --since '-24 hours' -n 30 --no-pager || printf 'AVISO: no se pudo consultar el journal\n'
} >"$temporal"
mv -- "$temporal" "$destino/ultimo.txt"
echo "Informe actualizado: $destino/ultimo.txt"
