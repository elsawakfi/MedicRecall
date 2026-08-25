#!/usr/bin/env bash
# Generate the MedicRecall API reference and apply the custom theme.
# Run from the flashcard/ directory: ./doc/build_docs.sh
set -euo pipefail

PKG_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PKG_ROOT"

echo "==> Resolving dependencies..."
flutter pub get

# Favicon must exist at dart-doc time (it's declared in dartdoc_options.yaml).
echo "==> Staging favicon..."
cp assets/newlogo.png doc/favicon.png

echo "==> Generating API docs with dart doc..."
# Allow non-zero exit (doc-comment errors are non-fatal — HTML is still written).
dart doc . || echo "(dart doc reported warnings — continuing)"

OUT_STATIC="doc/api/static-assets"
mkdir -p "$OUT_STATIC"

echo "==> Copying theme assets into $OUT_STATIC..."
cp doc/medicrecall.css "$OUT_STATIC/medicrecall.css"
cp assets/newlogo.png  "$OUT_STATIC/newlogo.png"

echo ""
echo "Done. Open: doc/api/index.html"
