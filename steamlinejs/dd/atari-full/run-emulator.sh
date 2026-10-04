#!/usr/bin/env sh
# Build, then start the workspace's persistent Altirra VBXE profile.
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
workspace_root=$(CDPATH= cd -- "$project_dir/../../.." && pwd)
runner="$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh"
bash "$project_dir/build.sh"
exec "$runner" "$project_dir/double-dragon.xex"
