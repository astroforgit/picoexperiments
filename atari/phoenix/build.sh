#!/usr/bin/env bash
# Build phoenix.xex (Atari XL/XE + VBXE). Requires MADS and Python 3 (numpy, Pillow).
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/rom.py >/dev/null
python3 tools/build.py
