#!/usr/bin/env bash
# serve.sh — Serve the mirrored site locally on http://localhost:8080/en/
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVE_ROOT="$WORKSPACE_DIR/site/www.geldofpoultry.com"
PORT="${1:-8080}"

if [ ! -d "$SERVE_ROOT" ]; then
  echo "ERROR: $SERVE_ROOT not found. Run 'bash scripts/mirror.sh' first." >&2
  exit 1
fi

echo "==> Serving offline site at http://localhost:$PORT/en/"
echo "    Press Ctrl-C to stop."
cd "$SERVE_ROOT"
python3 -m http.server "$PORT"
