#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 build_assets.py
mads intro.asm -o:dusiolek-intro.xex -t:intro.lab -l:intro.lst
