#!/usr/bin/env sh
# Run Agent USA in Altirra.
#   ./run.sh        rebuild decompiled/agent.asm and run the result
#   ./run.sh orig   run the original XEX
set -eu
cd "$(dirname "$0")"
if [ "${1:-}" = orig ]; then
    xex="Agent USA (1984)(Scholastic Wizware)(US).xex"
else
    decompiled/build.sh
    xex=decompiled/agent.xex
fi
exec ../../atari-vbxe-toolkit/scripts/run-xex.sh "$xex"
