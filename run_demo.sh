#!/usr/bin/env bash
# Shows the regression failing on the faulty implementation and passing on the fixed one.
cd "$(dirname "$0")"
echo "=== FAULTY ==="; IMPL=faulty python -m pytest -q 2>&1 | tail -n 12
echo; echo "=== FIXED ===";  IMPL=fixed  python -m pytest -q 2>&1 | tail -n 5
