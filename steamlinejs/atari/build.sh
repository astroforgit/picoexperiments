#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

node generate_levels.js
mads streamline-vbxe.asm \
  -o:streamline-vbxe.xex \
  -t:streamline-vbxe.lab \
  -l:streamline-vbxe.lst
node verify_build.js
