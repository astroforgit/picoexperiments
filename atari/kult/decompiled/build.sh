#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ "${1:-}" = regen ]; then python3 tools/generate.py; fi
python3 tools/build.py
