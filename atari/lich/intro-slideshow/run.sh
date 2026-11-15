#!/usr/bin/env bash
set -euo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$here/build.sh"
exec "$here/../../../atari-vbxe-toolkit/scripts/run-xex.sh" "$here/dusiolek-intro.xex"
