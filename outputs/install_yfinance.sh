#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

python3 -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install yfinance
python update_prices.py --output prices.json

echo
echo "yfinance installed locally and prices.json updated."
echo "Run the dashboard server with:"
echo "  ./serve_dashboard.sh"
