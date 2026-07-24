#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
node tools/extract.js
mads porter-vbxe.asm -x -o:porter-vbxe.xex -t:porter-vbxe.lab -l:porter-vbxe.lst
echo "Built porter-vbxe.xex"
