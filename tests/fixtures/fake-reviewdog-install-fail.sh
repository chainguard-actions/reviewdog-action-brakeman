#!/bin/sh
# Fake reviewdog installer: installs a reviewdog that exits 1 when fail-level != none and stdin non-empty
bindir=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -b) bindir="$arg" ;;
  esac
  prev="$arg"
done
if [ -n "$bindir" ]; then
  mkdir -p "$bindir"
  printf '#!/bin/sh\nfail_level="none"\nfor arg in "$@"; do\n  case "$arg" in\n    -fail-level=*) fail_level="${arg#-fail-level=}" ;;\n  esac\ndone\ninput="$(cat)"\nif [ "$fail_level" != "none" ] && [ -n "$input" ]; then\n  exit 1\nfi\nexit 0\n' > "$bindir/reviewdog"
  chmod +x "$bindir/reviewdog"
fi
exit 0
