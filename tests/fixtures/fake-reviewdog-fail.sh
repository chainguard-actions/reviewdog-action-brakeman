#!/bin/sh
# Fake reviewdog: exits 1 when -fail-level is not 'none' and stdin is non-empty
fail_level="none"
for arg in "$@"; do
  case "$arg" in
    -fail-level=*) fail_level="${arg#-fail-level=}" ;;
  esac
done
input="$(cat)"
if [ "$fail_level" != "none" ] && [ -n "$input" ]; then
  exit 1
fi
exit 0
