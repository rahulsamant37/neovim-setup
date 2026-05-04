#!/bin/bash
# Run all CP module tests in Neovim headless mode.
# Usage: bash tests/run_tests.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

failed=0
total=0
failed_files=""

for test_file in "$SCRIPT_DIR"/cp/*_test.lua; do
  [ -f "$test_file" ] || continue
  total=$((total + 1))
  relative="${test_file#$PROJECT_ROOT/}"
  echo "=== $relative ==="

  if nvim --headless --noplugin -u NONE -l "$test_file" 2>&1; then
    echo ""
  else
    echo "FAIL: $relative"
    echo ""
    failed=$((failed + 1))
    failed_files="$failed_files  $relative\n"
  fi
done

echo "=============================="
echo "Total: $total, Passed: $((total - failed)), Failed: $failed"

if [ "$failed" -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  printf "$failed_files"
  exit 1
fi

echo "All tests passed!"
