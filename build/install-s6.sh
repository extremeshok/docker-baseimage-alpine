#!/usr/bin/env bash -e

#curl -L https://keybase.io/justcontainers/key.asc | gpg --no-tty --batch --import --quiet

echo "ARCH: ${OVERLAY_ARCH}"

S6_VERSION="$(curl -L --silent "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
echo "Version: ${S6_VERSION}"
curl -L --silent -o /tmp/s6-overlay.tar.gz "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz"
curl -L --silent -o /tmp/s6-overlay.sig "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig"
gpg --no-tty --batch --verify --quiet /tmp/s6-overlay.sig s6-overlay.tar.gz 2> /dev/null
tar xfz /tmp/s6-overlay.tar.gz -C /
echo "Cleanup"
rm -f /tmp/s6-overlay.tar.gz
rm -f /tmp/s6-overlay.tar.gz.sig
