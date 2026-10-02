#!/usr/bin/env bash
# Build lich.xex (Atari XL/XE + VBXE).  Requires MADS; Python 3 is needed
# to regenerate data from the PICO-8 cartridge (--regenerate-data).
set -euo pipefail
cd "$(dirname "$0")"

if [[ "${1:-}" == "--regenerate-data" || ! -f gen/tables.asm ]]; then
    python3 tools/convert_cart.py
    python3 tools/make_data.py
fi

mads lich.asm -o:lich.xex -t:lich.lab -l:lich.lst
