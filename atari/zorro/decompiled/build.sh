#!/usr/bin/env sh
# Rebuild Zorro from the disassembly and check it against the original.
#   ./build.sh          -> zorro.xex, must equal the original file
#   ./build.sh regen    -> regenerate zorro.asm and data/ first
# Needs: mads, python3.
set -eu
cd "$(dirname "$0")"
ORIG="../Zorro (1985)(Datasoft)(US).xex"

if [ "${1:-}" = regen ] || [ ! -f zorro.asm ]; then
    python3 tools/disasm.py "$ORIG" .
fi
mads zorro.asm -o:zorro.xex -l:zorro.lst
if cmp -s zorro.xex "$ORIG"; then
    echo "OK: zorro.xex is identical to the original"
else
    python3 tools/verify.py zorro.xex "$ORIG"
    exit 1
fi
