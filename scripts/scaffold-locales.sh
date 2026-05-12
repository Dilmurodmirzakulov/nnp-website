#!/usr/bin/env bash
# scaffold-locales.sh — Create /uz and /ru as English-copy placeholders.
# Run AFTER mirror.sh: bash scripts/scaffold-locales.sh
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIRROR_ROOT="$WORKSPACE_DIR/site/www.geldofpoultry.com"
SOURCE_LANG="en"

if [ ! -d "$MIRROR_ROOT/$SOURCE_LANG" ]; then
  echo "ERROR: $MIRROR_ROOT/$SOURCE_LANG not found. Run scripts/mirror.sh first." >&2
  exit 1
fi

for loc in uz ru; do
  echo "==> Scaffolding /$loc from /$SOURCE_LANG..."
  rm -rf "$MIRROR_ROOT/$loc"
  cp -R "$MIRROR_ROOT/$SOURCE_LANG" "$MIRROR_ROOT/$loc"

  # Retag <html lang="en"> to <html lang="$loc"> (macOS-safe in-place sed)
  find "$MIRROR_ROOT/$loc" -name '*.html' -print0 | while IFS= read -r -d '' f; do
    sed -i '' "s/lang=\"$SOURCE_LANG\"/lang=\"$loc\"/g" "$f" 2>/dev/null || true
  done

  COUNT=$(find "$MIRROR_ROOT/$loc" -name '*.html' | wc -l | tr -d ' ')
  echo "  [OK] /$loc — $COUNT HTML files scaffolded (English placeholder, ready for translation)"
done

echo ""
echo "==> Scaffold complete. /$loc pages are English copies; replace text to translate."
