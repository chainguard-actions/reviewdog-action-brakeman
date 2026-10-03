#!/bin/sh
# Fake reviewdog installer: when called as "sh install.sh -b BINDIR VERSION",
# creates a fake reviewdog binary in BINDIR that records args and exits 0.
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
  printf '#!/bin/sh\necho "$@" > /tmp/reviewdog-args.txt\nexit 0\n' > "$bindir/reviewdog"
  chmod +x "$bindir/reviewdog"
fi
exit 0
