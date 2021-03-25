#!/usr/bin/env bash -e

#curl -L https://keybase.io/justcontainers/key.asc | gpg --no-tty --batch --import --quiet

echo "ARCH: ${OVERLAY_ARCH}"

SOCKLOG_VERSION="$(curl --silent "https://api.github.com/repos/just-containers/socklog-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')" \
echo "Version: ${SOCKLOG_VERSION}"
curl -L --silent -o /tmp/socklog-overlay.tar.gz "https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG_VERSION}/socklog-overlay-${OVERLAY_ARCH}.tar.gz"
curl -L --silent -o /tmp/socklog-overlay.sig "https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG_VERSION}/socklog-overlay-${OVERLAY_ARCH}.tar.gz.sig"
gpg --no-tty --batch --verify --quiet /tmp/socklog-overlay.sig socklog-overlay.tar.gz 2> /dev/null
tar xfz /tmp/socklog-overlay.tar.gz -C /
echo "Cleanup"
rm -f /tmp/socklog-overlay.tar.gz
rm -f /tmp/socklog-overlay.tar.gz.sig
