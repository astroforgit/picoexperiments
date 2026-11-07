#!/usr/bin/env sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
workspace_root=$(CDPATH= cd -- "$project_dir/../.." && pwd)
bash "$project_dir/build.sh"
exec "$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh" "$project_dir/pilka.xex"
