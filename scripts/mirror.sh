#!/usr/bin/env bash
# mirror.sh — Download geldofpoultry.com as a fully offline static site.
# Run from the workspace root: bash scripts/mirror.sh
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITE_DIR="$WORKSPACE_DIR/site"
TARGET="https://www.geldofpoultry.com/"
LOG="$WORKSPACE_DIR/wget-log.txt"

# Sanity-check that wget is available
if ! command -v wget &>/dev/null; then
  echo "ERROR: wget not found. Install it with: brew install wget" >&2
  exit 1
fi

echo "==> Mirror destination: $SITE_DIR"
echo "==> Log file: $LOG"
mkdir -p "$SITE_DIR"
cd "$SITE_DIR"

# ---------------------------------------------------------------------------
# Step 1: Crawl
# ---------------------------------------------------------------------------
wget \
  --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  --span-hosts \
  --domains=geldofpoultry.com,www.geldofpoultry.com,fonts.googleapis.com,fonts.gstatic.com,ajax.googleapis.com,cdnjs.cloudflare.com \
  --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36" \
  --wait=1 --random-wait \
  --no-check-certificate \
  --output-file="$LOG" \
  "$TARGET"

echo ""
echo "==> Crawl complete. Starting post-mirror fix-ups..."

# ---------------------------------------------------------------------------
# Step 2: Rewrite any remaining absolute URLs in HTML/CSS that --convert-links
#         missed (mainly CSS url(...) references in inline styles).
# ---------------------------------------------------------------------------
MIRROR_ROOT="$SITE_DIR/www.geldofpoultry.com"
if [ -d "$MIRROR_ROOT" ]; then
  echo "==> Rewriting residual absolute URLs in HTML files..."
  find "$MIRROR_ROOT" -name '*.html' -print0 | while IFS= read -r -d '' f; do
    sed -i '' \
      's|https://www\.geldofpoultry\.com/|/|g' \
      "$f" 2>/dev/null || true
  done

  echo "==> Rewriting residual absolute URLs in CSS files..."
  find "$MIRROR_ROOT" -name '*.css' -print0 | while IFS= read -r -d '' f; do
    sed -i '' \
      's|https://www\.geldofpoultry\.com/|/|g' \
      "$f" 2>/dev/null || true
  done

  # ---------------------------------------------------------------------------
  # Step 3: Report 404s from the wget log so we know what's missing
  # ---------------------------------------------------------------------------
  echo ""
  echo "==> Checking for 404 errors in the crawl log..."
  ERRORS=$(grep -c " 404 " "$LOG" 2>/dev/null || true)
  if [ "$ERRORS" -gt 0 ]; then
    echo "WARNING: $ERRORS asset(s) returned 404. Details:"
    grep " 404 " "$LOG" | sed 's/^/  /'
  else
    echo "No 404 errors found."
  fi

  # ---------------------------------------------------------------------------
  # Step 4: Confirm all 4 language directories exist
  # ---------------------------------------------------------------------------
  echo ""
  echo "==> Verifying language directories..."
  for lang in en fr nl ar; do
    if [ -d "$MIRROR_ROOT/$lang" ]; then
      COUNT=$(find "$MIRROR_ROOT/$lang" -name '*.html' | wc -l | tr -d ' ')
      echo "  [OK] /$lang  ($COUNT HTML files)"
    else
      echo "  [MISSING] /$lang — wget may not have followed the language link. Re-run with: wget ... https://www.geldofpoultry.com/$lang/"
    fi
  done
else
  echo "WARNING: Mirror root $MIRROR_ROOT not found. The crawl may have failed."
  exit 1
fi

echo ""
echo "==> Done. Run 'bash serve.sh' to open the site locally."
