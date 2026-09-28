#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./build.sh
python3 tools/test_runtime.py
python3 tools/test_sheep.py
python3 tools/test_encounters.py
python3 tools/test_double_fire.py
python3 tools/test_moods.py
python3 tools/test_playthrough.py
