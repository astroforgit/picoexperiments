#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/build_assets.py
mads star-fisher.asm -o:star-fisher.xex -t:star-fisher.lab -l:star-fisher.lst
