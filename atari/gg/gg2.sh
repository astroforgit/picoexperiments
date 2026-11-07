#!/usr/bin/env bash
# Alternative build gng2.xex: no smooth scrolling between pictures (the
# playfield moves only when a new picture is shown, like commit 384dc4fa;
# the sprites never lag the background).
set -euo pipefail
cd "$(dirname "$0")"
[ -f disk/09.GA.prg ] || python3 tools/d64.py
GG_SMOOTH=0 GG_OUT=gng2.xex python3 tools/build.py
