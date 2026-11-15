#!/usr/bin/env bash
# Build celeste.xex (Atari XL/XE + VBXE).  Requires MADS; Python 3 is needed
# to regenerate data from the PICO-8 cartridge (--regenerate-data).
set -euo pipefail
cd "$(dirname "$0")"

if [[ "${1:-}" == "--regenerate-data" || ! -f gen/tables.asm ]]; then
    python3 tools/make_data.py
fi

mads celeste.asm -o:celeste.xex -t:celeste.lab -l:celeste.lst
