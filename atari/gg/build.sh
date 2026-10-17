#!/usr/bin/env bash
# Build gng.xex (Ghosts'n Goblins Arcade for Atari XL/XE + VBXE).
# Requires MADS and Python 3 (py65, numpy, Pillow for the analysis tools).
set -euo pipefail
cd "$(dirname "$0")"
[ -f disk/09.GA.prg ] || python3 tools/d64.py
python3 tools/build.py
