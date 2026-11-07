#!/usr/bin/env bash
# Build double-dragon.xex (Atari XL/XE + VBXE). Requires MADS and Python 3.
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/build.py
