#!/usr/bin/env sh
set -eu
export HEROES_ART_PROFILE="${HEROES_ART_PROFILE:-vbxe-v2}"
cd "$(dirname "$0")"
node tools/build-medieval.js
node tools/build-assets.js
node tools/build-battle.js
mads city-vbxe.asm -x -o:city-vbxe.xex -t:generated/city-vbxe.lab -l:generated/city-vbxe.lst
node tools/build-boot-atr.js
node tools/verify-build.js
# Keep the runner copies in ../ in step with this build.
cp city-vbxe.xex ../prince-and-the-nymph.xex
cp generated/heroes-story.atr ../prince-and-the-nymph.atr
cp city-vbxe.atr ../prince-and-the-nymph-boot.atr
