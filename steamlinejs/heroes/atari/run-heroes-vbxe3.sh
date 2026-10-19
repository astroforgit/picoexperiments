#!/usr/bin/env sh
# Compatibility entry point for Prince and the Nimf.
set -eu
runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec sh "$runner_dir/run-prince-and-the-nimf.sh" "$@"
