#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT="${PORT:-8080}"
PRICE_REFRESH_SECONDS="${PRICE_REFRESH_SECONDS:-3600}"
PYTHON_BIN="python3"

if [ -x ".venv/bin/python" ]; then
  PYTHON_BIN=".venv/bin/python"
fi

echo "Serving 13F dashboard at:"
echo "  http://localhost:${PORT}/13f_dashboard.html"
echo
if "${PYTHON_BIN}" - <<'PY' >/dev/null 2>&1
import yfinance
PY
then
  echo "Starting yfinance price updater every ${PRICE_REFRESH_SECONDS}s."
  "${PYTHON_BIN}" update_prices.py --output prices.json --loop "${PRICE_REFRESH_SECONDS}" &
  PRICE_PID=$!
  trap 'kill "${PRICE_PID}" 2>/dev/null || true' EXIT
else
  echo "Price updater skipped: yfinance is not installed."
  echo "Install once with: ./install_yfinance.sh"
  echo
fi

echo "Press Ctrl+C to stop."

python3 -m http.server "${PORT}"
