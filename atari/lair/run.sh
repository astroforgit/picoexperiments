#!/usr/bin/env bash
# Build lair.xex and start it in Altirra (from WSL) with the persistent VBXE
# profile of atari-vbxe-toolkit.   ./run.sh [--no-build]
set -euo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ "${1:-}" != "--no-build" ]]; then
    "$here/build.sh" >/dev/null
fi
exec "$here/../../atari-vbxe-toolkit/scripts/run-xex.sh" "$here/lair.xex"
