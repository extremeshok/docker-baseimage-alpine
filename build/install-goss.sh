#!/usr/bin/env bash -e

echo "ARCH: ${OVERLAY_ARCH}"

GOSS_VERSION="$(curl --silent "https://api.github.com/repos/aelsabbahy/goss/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
echo "Version: ${GOSS_VERSION}"
curl -L --silent -o "/tmp/goss-linux-${OVERLAY_ARCH}" "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${OVERLAY_ARCH}"
curl -L --silent -o /tmp/goss.sha256 "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${OVERLAY_ARCH}.sha256"
sha256sum -s -c /tmp/goss.sha256
mv -f "/tmp/goss-linux-${OVERLAY_ARCH}" /bin/goss
echo "Cleanup"
chmod +x /bin/goss
rm -rf /tmp/goss.sha256
