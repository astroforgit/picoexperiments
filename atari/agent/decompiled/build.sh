#!/usr/bin/env sh
# Rebuild Agent USA from the disassembly and check it against the original.
#   ./build.sh          -> agent.xex, must equal the original file
#   ./build.sh regen    -> regenerate agent.asm first
# Needs: mads, python3.
set -eu
cd "$(dirname "$0")"
ORIG="../Agent USA (1984)(Scholastic Wizware)(US).xex"

if [ "${1:-}" = regen ] || [ ! -f agent.asm ]; then
    python3 tools/disasm.py "$ORIG" .
fi
out=$(mads agent.asm -o:agent.xex -l:agent.lst) || { echo "$out" | grep -v "^Writing"; exit 1; }
if cmp -s agent.xex "$ORIG"; then
    echo "OK: agent.xex is identical to the original"
else
    python3 tools/verify.py agent.xex "$ORIG"
    exit 1
fi
