#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./build.sh
exec ../../../atari-vbxe-toolkit/scripts/run-xex.sh "$PWD/star-fisher.xex"
