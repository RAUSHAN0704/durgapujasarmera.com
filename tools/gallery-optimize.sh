#!/usr/bin/env bash
#
# gallery-optimize.sh — yearly gallery photo pipeline for durgapujasarmera.com
#
# For each source photo it produces, into assets/gallery/<year>/:
#   dp<year>-NN-thumb.webp   ~400px wide, grid thumbnail (tiny)
#   dp<year>-NN-thumb.jpg    JPEG fallback for the thumbnail
#   dp<year>-NN.webp         ~1600px wide, full image for the lightbox
#   dp<year>-NN.jpg          JPEG fallback for the full image
#
# Usage:
#   tools/gallery-optimize.sh <year> <source-folder>
# Example:
#   tools/gallery-optimize.sh 2026 ~/Downloads/2026_Durga_Puja_Images
#
# Requires: sips (macOS built-in) and cwebp (`brew install webp`).
# Idempotent per run: it numbers outputs dp<year>-01, -02, … in filename order.
# It does NOT edit gallery.html — it only produces the image files. Add the
# tiles with the <picture> snippet printed at the end.

set -euo pipefail

YEAR="${1:-}"
SRC="${2:-}"

if [[ -z "$YEAR" || -z "$SRC" ]]; then
  echo "Usage: $0 <year> <source-folder>" >&2
  exit 1
fi
if ! command -v cwebp >/dev/null 2>&1; then
  echo "cwebp not found — run: brew install webp" >&2
  exit 1
fi
if [[ ! -d "$SRC" ]]; then
  echo "Source folder not found: $SRC" >&2
  exit 1
fi

# Resolve output dir relative to this script's repo root
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO_ROOT/assets/gallery/$YEAR"
mkdir -p "$OUT"

FULL_MAX=1600      # full image longest side
THUMB_MAX=400      # thumbnail longest side
FULL_Q=72          # jpeg quality full
THUMB_Q=70         # jpeg quality thumb
WEBP_FULL_Q=78     # webp quality full
WEBP_THUMB_Q=72    # webp quality thumb

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

i=1
shopt -s nullglob nocaseglob
for f in "$SRC"/*.{jpg,jpeg,png,heic,webp,avif}; do
  [[ -f "$f" ]] || continue
  n=$(printf "%02d" "$i")
  base="dp${YEAR}-${n}"

  # Full-size JPEG (fallback) + WebP
  sips -s format jpeg -Z "$FULL_MAX" -s formatOptions "$FULL_Q" "$f" --out "$OUT/${base}.jpg" >/dev/null 2>&1
  cwebp -quiet -q "$WEBP_FULL_Q" "$OUT/${base}.jpg" -o "$OUT/${base}.webp" >/dev/null 2>&1

  # Thumbnail JPEG (fallback) + WebP
  sips -s format jpeg -Z "$THUMB_MAX" -s formatOptions "$THUMB_Q" "$f" --out "$OUT/${base}-thumb.jpg" >/dev/null 2>&1
  cwebp -quiet -q "$WEBP_THUMB_Q" "$OUT/${base}-thumb.jpg" -o "$OUT/${base}-thumb.webp" >/dev/null 2>&1

  echo "  $base  <- $(basename "$f")"
  i=$((i+1))
done

count=$((i-1))
echo ""
echo "Done: $count image(s) written to assets/gallery/$YEAR/"
echo ""
echo "Add each to gallery.html inside the $YEAR .gallery-grid using this pattern:"
cat <<SNIPPET

                <div class="col-12 col-md-4 gallery-item">
                    <div class="gImg mb-3">
                        <a href="assets/gallery/$YEAR/dp$YEAR-01.jpg" class="gallery-thumb">
                            <picture>
                                <source srcset="assets/gallery/$YEAR/dp$YEAR-01-thumb.webp" type="image/webp">
                                <img src="assets/gallery/$YEAR/dp$YEAR-01-thumb.jpg"
                                     class="img-fluid rounded-3" loading="lazy"
                                     alt="दुर्गा पूजा $YEAR — सरमेरा">
                            </picture>
                        </a>
                    </div>
                </div>
SNIPPET
