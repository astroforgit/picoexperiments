#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"
mads vbxe-probe.asm -o:vbxe-probe.xex -t:vbxe-probe.lab -l:vbxe-probe.lst

size=$(wc -c < vbxe-probe.xex)
if [ "$size" -lt 32 ]; then
    echo "probe build is unexpectedly small: $size bytes" >&2
    exit 1
fi
echo "built vbxe-probe.xex ($size bytes)"

