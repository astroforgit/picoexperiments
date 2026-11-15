#!/usr/bin/env bash
# Build, then start phoenix.xex in the persistent Altirra VBXE profile.
set -euo pipefail
cd "$(dirname "$0")"
./build.sh
exec ../../atari-vbxe-toolkit/scripts/run-xex.sh phoenix.xex
