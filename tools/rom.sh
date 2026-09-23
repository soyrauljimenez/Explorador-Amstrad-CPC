#!/bin/bash
# Ensambla una version del explorador y, si se indica la placa, la sube.
#
#   ./tools/rom.sh v2                    solo ensamblar: build/EXPLOR2.ROM
#   M4=192.168.1.42 ./tools/rom.sh v2 12 ensamblar y subir al slot 12
#
# La subida manda 'slotnum' antes que el fichero: el M4 procesa los
# campos en orden y, al reves, la ROM iria a parar al slot 0. Despues
# relee el listado de slots para confirmar, porque el M4 contesta 200
# aunque no haya guardado nada.
set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:?uso: $0 v1|v2 [slot] [nombre]}"
SLOT="${2:-12}"
NOMBRE="${3:-EXPLORADOR}"
SRC="$DIR/src/$VER/explorador.asm"
OUT="$DIR/build/EXPLOR${VER#v}.ROM"
[ -f "$SRC" ] || { echo "no existe $SRC"; exit 1; }

mkdir -p "$DIR/build"
rm -f "$OUT"                 # si el ensamblado falla, que no quede el anterior
(cd "$DIR/src/$VER" && "$DIR/tools/rasm" explorador.asm -ob "$OUT" >/dev/null)
rm -f "$DIR/src/$VER/rasmoutput.sym"
[ -f "$OUT" ] || { echo "ERROR: el ensamblado no genero salida"; exit 1; }
TAM=$(wc -c < "$OUT" | tr -d ' ')
[ "$TAM" -eq 16384 ] || { echo "ERROR: la ROM mide $TAM bytes, deben ser 16384"; exit 1; }
echo "ensamblada: $OUT"

[ -n "$M4" ] || exit 0

curl -s -m 40 -F "slotnum=$SLOT" -F "slotname=$NOMBRE" \
     -F "uploadedfile=@$OUT;filename=$(basename "$OUT")" \
     "http://$M4/roms.shtml" -o /dev/null -w "subida    : http:%{http_code}\n"
sleep 2

echo "slots tras la subida:"
curl -s -m 10 "http://$M4/roms.shtml" | tr '\n' ' ' | python3 -c "
import re,sys
h=sys.stdin.read()
for n,v in re.findall(r'Rom slot (\d+)</td><td[^>]*>(.*?)</td>', h):
    v=re.sub(r'<!--.*?-->','',v); v=re.sub(r'<[^>]*>','',v).strip()
    if v: print(f'  slot {n:>2}: {v}')
"
read -p "reiniciar el M4? [s/N] " r
[ "$r" = "s" ] || exit 0
curl -s -m 10 "http://$M4/config.cgi?mres=M4+Reset" -o /dev/null -w "reinicio  : http:%{http_code}\n"
