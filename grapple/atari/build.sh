#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"
node generate_assets.js
mads grapple-vbxe.asm \
  -o:grapple-vbxe.xex \
  -t:grapple-vbxe.lab \
  -l:grapple-vbxe.lst
node verify_build.js
