#!/usr/bin/env bash
# Build lair.xex (Atari XL/XE + VBXE).  Requires MADS; Python 3 (with lupa,
# numpy and Pillow) is needed to regenerate the data from the cartridge.
set -euo pipefail
cd "$(dirname "$0")"

if [[ "${1:-}" == "--regenerate-data" || ! -f gen/tables.asm ]]; then
    python3 tools/convert_cart.py
    python3 tools/make_data.py
fi

mads lair.asm -o:lair.xex -t:lair.lab -l:lair.lst
