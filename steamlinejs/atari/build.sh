#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

node generate_levels.js
node generate_tiles.js
python3 generate_title.py
python3 generate_story.py
node generate_data.js
mads bimbaj.asm \
  -o:bimbaj.xex \
  -t:bimbaj.lab \
  -l:bimbaj.lst
node verify_build.js
