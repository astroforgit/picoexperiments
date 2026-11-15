#!/bin/sh
set -eu
cd "$(dirname "$0")"
python3 build.py
python3 -m unittest test_build -v
