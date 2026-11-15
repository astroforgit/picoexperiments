#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ "${1:-}" == "--regenerate-assets" ]]; then
    python3 make_assets.py
fi

mads race-vbxe.asm -o:race-vbxe.xex
