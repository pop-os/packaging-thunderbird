#!/usr/bin/env bash

set -e

if [ -z "$1" ]
then
    echo "$0 [version]" >&2
    exit 1
fi
VERSION="$1"

curl \
    -o SHA256SUMS \
    "https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/${VERSION}/SHA256SUMS"

dch \
    --newversion "2:${VERSION}" \
    --distribution jammy \
    "https://www.mozilla.org/en-US/thunderbird/${VERSION}/releasenotes/"
