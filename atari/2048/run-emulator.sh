#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"

"$script_dir/build.sh"
exec "$repo_root/atari-vbxe-toolkit/scripts/run-xex.sh" "$script_dir/2048-vbxe.xex"
