#!/usr/bin/env bash -e


ARCHITECTURE=""
case $(uname -m) in
    i386)   ARCHITECTURE="386" ;;
    i686)   ARCHITECTURE="386" ;;
    x86_64) ARCHITECTURE="amd64" ;;
    arm)    dpkg --print-architecture | grep -q "arm64" && ARCHITECTURE="arm64" || ARCHITECTURE="arm" ;;
    *) echo "ERROR: Unknown architecture" ; exit 1 ;;
esac

echo "ARCH: ${ARCHITECTURE}"

GOSS_VERSION="$(curl --silent "https://api.github.com/repos/aelsabbahy/goss/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
echo "Version: ${GOSS_VERSION}"
curl -L --silent -o "/tmp/goss-linux-${ARCHITECTURE}" "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCHITECTURE}"
curl -L --silent -o /tmp/goss.sha256 "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCHITECTURE}.sha256"
sha256sum -s -c /tmp/goss.sha256
mv -f "/tmp/goss-linux-${ARCHITECTURE}" /bin/goss
echo "Cleanup"
chmod +x /bin/goss
rm -rf /tmp/goss.sha256
