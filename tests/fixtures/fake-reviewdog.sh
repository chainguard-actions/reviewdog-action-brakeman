#!/bin/sh
# Fake reviewdog: records args and exits 0
echo "$@" > /tmp/reviewdog-args.txt
exit 0
