#!/usr/bin/env sh
# Build SPEEDMAZA GRAND PRIX: ./build.sh  ->  grandprix.xex
#   ./build.sh auto  ->  grandprix_auto.xex (car 1 drives itself; testing)
# Needs mads, python3 with numpy and Pillow, and ../decompiled/unpacked.bin
# (made by ../decompiled/build.sh regen).
set -eu
cd "$(dirname "$0")"
python3 tools/make_data.py ../picospeed.txt ../decompiled/unpacked.bin .
if [ "${1:-}" = auto ]; then
    mads grandprix.asm -d:AUTOPILOT=1 -o:grandprix_auto.xex -l:grandprix_auto.lst
    ls -l grandprix_auto.xex
else
    mads grandprix.asm -o:grandprix.xex -l:grandprix.lst -t:grandprix.lab
    ls -l grandprix.xex
fi
