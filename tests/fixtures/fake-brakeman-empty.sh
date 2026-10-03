#!/bin/sh
# Fake brakeman: writes an empty report to --output path, records workdir
echo "$(pwd)" > /tmp/brakeman-workdir.txt
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    --output) out="$arg" ;;
  esac
  prev="$arg"
done
if [ -n "$out" ]; then
  : > "$out"
fi
exit 0
