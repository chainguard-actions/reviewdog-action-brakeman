#!/bin/sh
# Fake gem: intercepts 'gem install brakeman', installs fake brakeman binary
case "$*" in
  *install*brakeman*)
    cp /tmp/fake-brakeman-empty.sh /tmp/fake-bin/brakeman
    chmod +x /tmp/fake-bin/brakeman
    exit 0
    ;;
esac
# For other gem commands, try real gem if available
for gempath in /usr/bin/gem /usr/local/bin/gem; do
  if [ -x "$gempath" ] && [ "$gempath" != "$0" ]; then
    exec "$gempath" "$@"
  fi
done
exit 0
