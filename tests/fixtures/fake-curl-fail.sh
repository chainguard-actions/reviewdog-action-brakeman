#!/bin/sh
# Fake curl: intercepts reviewdog installer URL, serves fake fail installer.
# Supports both "curl URL | sh" (stdout) and hardened "curl -o FILE URL" (write to file).
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *reviewdog*)
    if [ -n "$out" ]; then
      cat /tmp/fake-reviewdog-install-fail.sh > "$out"
    else
      cat /tmp/fake-reviewdog-install-fail.sh
    fi
    exit 0
    ;;
esac
# For any other URL, try real curl if available, otherwise succeed silently
if [ -x /usr/bin/curl ]; then
  exec /usr/bin/curl "$@"
fi
exit 0
