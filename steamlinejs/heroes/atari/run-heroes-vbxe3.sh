#!/usr/bin/env sh
# Compatibility entry point for Prince and the Nymph.
set -eu
runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec sh "$runner_dir/run-prince-and-the-nymph.sh" "$@"
