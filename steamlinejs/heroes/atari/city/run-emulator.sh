#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
./build.sh
exec ../../../../atari-vbxe-toolkit/scripts/run-xex.sh "$PWD/city-vbxe.xex"
