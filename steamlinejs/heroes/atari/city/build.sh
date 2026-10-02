#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
node tools/build-medieval.js
node tools/build-assets.js
node tools/build-battle.js
mads city-vbxe.asm -x -o:city-vbxe.xex -t:generated/city-vbxe.lab -l:generated/city-vbxe.lst
node tools/verify-build.js
