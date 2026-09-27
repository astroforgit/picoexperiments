#!/usr/bin/env sh
# Rebuild SPEEDmaza from the disassembly and check it against the original.
#   ./build.sh          -> speedmaza.xex (uncompressed, runs like the original)
#   ./build.sh regen    -> also re-unpack the original and regenerate the .asm
# Needs: mads, python3; "regen" also needs py65 (pip install py65).
set -eu
cd "$(dirname "$0")"
ORIG="../SPEEDmaza (2014)(Husak, Jakub)(PL)(en)[a].xex"
IMAGE=unpacked.bin

if [ "${1:-}" = regen ] || [ ! -f "$IMAGE" ]; then
    python3 tools/unpack.py "$ORIG" "$IMAGE"
    python3 tools/disasm.py "$IMAGE" .
fi
mads speedmaza.asm -o:speedmaza.xex -l:speedmaza.lst
python3 tools/verify.py speedmaza.xex "$IMAGE"
