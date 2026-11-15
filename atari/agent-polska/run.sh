#!/usr/bin/env sh
# Rebuild Agent Polska from the original XEX and run it in Altirra.
set -eu
cd "$(dirname "$0")"
python3 make_polska.py
exec ../../atari-vbxe-toolkit/scripts/run-xex.sh agent-polska.xex
