#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)

"$script_dir/build.sh"
exec "$repo_root/atari-vbxe-toolkit/scripts/run-xex.sh" \
    "$script_dir/grapple-vbxe.xex"
