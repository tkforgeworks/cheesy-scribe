#!/usr/bin/env bash
# Rebuilds the first-use tour's pictures and highlights (CHEESE-49): renders
# every frame from the demo notebook, converts them to 720 px WebP in
# assets/tour/, and regenerates lib/features/tour/tour_highlights.dart.
# Needs ImageMagick (`magick`). Run from the repo root after any change
# that alters a screen shown in the tour.
set -euo pipefail

cd "$(dirname "$0")/../.."
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT

TOUR_OUT="$out" flutter test --concurrency=4 tool/visual/render_tour_test.dart

mkdir -p assets/tour
rm -f assets/tour/*.webp
for png in "$out"/*.png; do
  name=$(basename "$png" .png)
  magick "$png" -resize 720x1600 -quality 82 "assets/tour/$name.webp"
done

dart run tool/visual/write_tour_highlights.dart "$out/rects"
dart format lib/features/tour/tour_highlights.dart

echo "Wrote $(ls assets/tour/*.webp | wc -l) frames ($(du -sh assets/tour | cut -f1))."
