#!/usr/bin/env sh
set -eu

# BUILD_DIR keeps a variant build out of the source tree, so an alternative
# hero can be assembled without replacing the default one. Every generated
# file lands there; only fidelity.asm and the assembly come from here.
#
# The assembly is copied into BUILD_DIR before assembling rather than being
# assembled in place: mads resolves icl/ins relative to the directory holding
# the source file, so assembling from here would quietly pick up this
# directory's generated files and build the wrong character.
cd "$(dirname "$0")"
source_dir=$(pwd)
build_dir=${BUILD_DIR:-$source_dir}
mkdir -p "$build_dir"

node "$source_dir/generate_assets.js"
if [ "$build_dir" != "$source_dir" ]; then
    cp "$source_dir/grapple-vbxe.asm" "$build_dir/grapple-vbxe.asm"
fi
cd "$build_dir"
mads grapple-vbxe.asm \
    -i:"$source_dir" \
    -o:grapple-vbxe.xex \
    -t:grapple-vbxe.lab \
    -l:grapple-vbxe.lst
node "$source_dir/verify_build.js"
