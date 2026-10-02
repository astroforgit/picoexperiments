#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/make_assets.py
"${MADS:-mads}" double-dragon-vbxe.asm -x -o:double-dragon-vbxe.xex -t:generated/double-dragon-vbxe.lab -l:generated/double-dragon-vbxe.lst
python3 tools/verify_xex.py
sha256sum double-dragon-vbxe.xex > double-dragon-vbxe.sha256
