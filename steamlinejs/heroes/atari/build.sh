#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"
node generate_data.js
mads heroes-vbxe.asm \
  -o:heroes-vbxe.xex \
  -t:heroes-vbxe.lab \
  -l:heroes-vbxe.lst
node verify_build.js
