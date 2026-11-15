#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ "${1:-}" == "--regenerate-assets" ]]; then python3 make_views.py; fi
mads 2048-vbxe.asm -o:2048-vbxe.xex
