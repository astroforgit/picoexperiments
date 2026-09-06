#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/make_assets.py
mads sven-vbxe.asm -x -o:sven-vbxe.xex -t:generated/sven-vbxe.lab -l:generated/sven-vbxe.lst
