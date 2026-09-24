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
    echo
    echo -n 'Equipo: '; hostname
    echo
    echo 'Tiempo de actividad y carga:'; uptime
    echo
    echo 'Disco:'; df -h /
    echo
    echo 'Memoria:'; free -h
    echo
    echo 'Servicios fallidos:'
    systemctl --failed --no-pager || echo 'AVISO: no se pudo consultar systemd'
    echo
    echo 'Errores recientes visibles para esta cuenta:'
    journalctl -p err --since '-24 hours' -n 30 --no-pager || echo 'AVISO: no se pudo consultar el journal'
} >"$temporal"
mv -- "$temporal" "$destino/ultimo.txt"
echo "Informe actualizado: $destino/ultimo.txt"
