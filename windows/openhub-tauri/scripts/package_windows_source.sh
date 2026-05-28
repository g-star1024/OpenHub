#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
TMPDIR="$(mktemp -d /tmp/openhub-windows-source.XXXXXX)"

mkdir -p "$DIST_DIR" "$TMPDIR/OpenHub-Windows"
rsync -a \
  --exclude "node_modules/" \
  --exclude "src-tauri/target/" \
  --exclude ".DS_Store" \
  "$ROOT_DIR/windows/openhub-tauri/" "$TMPDIR/OpenHub-Windows/"

(cd "$TMPDIR" && zip -qr "OpenHub-Windows-source.zip" OpenHub-Windows)
mv "$TMPDIR/OpenHub-Windows-source.zip" "$DIST_DIR/OpenHub-Windows-source.zip"
rm -rf "$TMPDIR"

echo "$DIST_DIR/OpenHub-Windows-source.zip"
