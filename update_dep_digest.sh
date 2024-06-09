#!/bin/sh

set -exo pipefail

versions="$1"
stampfile="$2"
digest="$(printf %s "$versions" | sha1sum -b | cut -f 1 -d " ")"

if [ ! -e "$stampfile" ] || [ ! -s "$stampfile" ] || [ "$(echo "$digest" | sort -u -- "$stampfile" - | wc -l)" -ne 1 ]; then
    mkdir -p "$(dirname "$stampfile")"
    echo "$digest" > "$stampfile"
fi
