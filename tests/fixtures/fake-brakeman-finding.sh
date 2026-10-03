#!/bin/sh
# Fake brakeman: outputs a tab-separated finding to --output path
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    --output) out="$arg" ;;
  esac
  prev="$arg"
done
FINDING="app/controllers/application_controller.rb	10	Warning	SQL Injection"
if [ -n "$out" ]; then
  printf '%s\n' "$FINDING" > "$out"
else
  printf '%s\n' "$FINDING"
fi
exit 0
