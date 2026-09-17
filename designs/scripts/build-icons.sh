#!/usr/bin/env bash
# Regenerate the root-level favicon and apple-touch-icon from favicon.svg.
#
# Prerequisite: ImageMagick 7 (the `magick` command). On macOS: `brew install imagemagick`.
#
# Pipeline notes:
#   -background none      → make sure transparent SVG regions stay alpha=0 in the raster
#                           (default is white; that's what caused the earlier white-corner bug)
#   -density 512          → render the SVG at high resolution first, so downsampling has
#                           smooth source pixels to work with (crisper edges)
#   -filter Lanczos       → Lanczos downsampling; sharpest of the common filters
#   PNG32:                → force RGBA PNG output (preserves the alpha channel)
#
# Run from the repo root:
#   ./designs/scripts/build-icons.sh
#
# The extract-m-path.cjs script (same folder) generates the SVG's <path> data
# from the Comfortaa Bold TTF. Only re-run that if the mark itself changes.

set -euo pipefail

cd "$(dirname "$0")/../.."   # repo root

SRC=favicon.svg
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "→ rasterizing $SRC at 16/32/48 for favicon.ico"
for size in 16 32 48; do
  magick -background none -density 512 "$SRC" -filter Lanczos -resize ${size}x${size} PNG32:"$TMP/fav-${size}.png"
done

echo "→ combining into favicon.ico (multi-resolution)"
magick "$TMP/fav-16.png" "$TMP/fav-32.png" "$TMP/fav-48.png" favicon.ico

echo "→ rasterizing apple-touch-icon.png at 180"
magick -background none -density 512 "$SRC" -filter Lanczos -resize 180x180 PNG32:apple-touch-icon.png

echo "done."
ls -la favicon.ico apple-touch-icon.png
