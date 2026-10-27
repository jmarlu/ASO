#!/usr/bin/env bash
# Uso: copia.sh ORIGEN DESTINO. Conserva las cinco últimas copias completas.
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
umask 077
[[ $# -eq 2 && $1 = /* && $2 = /* && -d $1 && -d $2 && -w $2 ]] || {
    echo 'Uso: copia.sh ORIGEN_ABSOLUTO DESTINO_ABSOLUTO_EXISTENTE_Y_ESCRIBIBLE' >&2; exit 2;
}
origen=$(realpath -- "$1")
destino=$(realpath -- "$2")
[[ $origen != / && $destino != "$origen" && $destino != "$origen/"* ]] || {
    echo 'El destino debe estar fuera del origen; no se admite copiar /' >&2; exit 2;
}
exec 9>"$destino/.copia.lock"
flock -n -E 75 9 || { echo 'Copia ya en ejecución' >&2; exit 75; }
temporal=$(mktemp "$destino/.copia.XXXXXX")
trap 'rm -f -- "$temporal"' EXIT
archivo="$destino/copia-$(date -u +%Y%m%dT%H%M%S%N).tar.gz"
tar -czf "$temporal" -C "$origen" .
tar -tzf "$temporal" >/dev/null
mv -- "$temporal" "$archivo"
# Solo archivos del patrón propio, en este directorio; nombres generados sin saltos de línea.
mapfile -t copias < <(find "$destino" -maxdepth 1 -type f -name 'copia-*.tar.gz' -printf '%f\n' | LC_ALL=C sort -r)
for ((i=5; i<${#copias[@]}; i++)); do
    rm -- "$destino/${copias[i]}"
done
echo "Copia verificada: $archivo"
