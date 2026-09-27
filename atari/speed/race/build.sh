#!/usr/bin/env sh
# Build SPEEDMAZA RACE: ./build.sh  ->  race.xex
#   ./build.sh auto  ->  race_auto.xex (drives itself; for testing)
# Needs mads, python3 with numpy and Pillow, and ../decompiled/unpacked.bin
# (made by ../decompiled/build.sh regen).
set -eu
cd "$(dirname "$0")"
python3 tools/make_data.py ../picospeed.txt ../decompiled/unpacked.bin .
if [ "${1:-}" = auto ]; then
    mads race.asm -d:AUTOPILOT=1 -o:race_auto.xex -l:race_auto.lst
    ls -l race_auto.xex
else
    mads race.asm -o:race.xex -l:race.lst -t:race.lab
    ls -l race.xex
fi
