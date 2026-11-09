#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 tools/make_icon.py petscope/sce_sys/icon0.png
cd petscope
make
cp -f ./*.pkg ../
