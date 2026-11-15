#!/usr/bin/env bash
# Build cauldron.xex (Cauldron for Atari XL/XE + VBXE).
# Requires MADS and Python 3 (py65 and numpy for the C64 model the build uses).
set -euo pipefail
cd "$(dirname "$0")"
[ -f disk/PALACE.prg ] || python3 tools/d64.py
python3 tools/build.py
