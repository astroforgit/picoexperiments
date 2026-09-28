#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

node generate_levels.js
node generate_tiles.js
python3 generate_title.py
python3 generate_story.py
mads streamline-atari.asm \
  -o:streamline-atari.xex \
  -t:streamline-atari.lab \
  -l:streamline-atari.lst
node verify_build.js
