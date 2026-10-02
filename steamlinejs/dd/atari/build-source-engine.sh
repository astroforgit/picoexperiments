#!/usr/bin/env bash
# Build the full-source conversion components. This does not produce an XEX
# until engine relocation and the native hardware backend are implemented.
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/build_source_engine.py
python3 tools/build_source_terrain.py
"${MADS:-mads}" generated/source-engine/terrain.asm -o:generated/source-engine/terrain-assembled.bin -t:generated/source-engine/terrain.lab
python3 tools/pack_source_chr.py
"${MADS:-mads}" source-engine/unpack.asm -o:generated/source-engine/unpack.bin -t:generated/source-engine/unpack.lab
"${MADS:-mads}" source-engine/expand.asm -o:generated/source-engine/expand.bin -t:generated/source-engine/expand.lab
python3 tools/test_source_engine.py
python3 tools/test_source_terrain.py
python3 tools/test_source_chr.py
