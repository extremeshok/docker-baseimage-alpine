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

GOSS_VERSION="$(curl -L --silent "https://api.github.com/repos/aelsabbahy/goss/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
echo "Version: ${GOSS_VERSION}"
curl -L --silent -o "/tmp/goss" "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCHITECTURE}"
GOSS_SHA256="$(curl -L --silent "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCHITECTURE}.sha256" | cut -d" " -f 1)"

# requires 2 spaces
echo "${GOSS_SHA256}  /tmp/goss" | sha256sum -c -s - 2>&1

mv -f "/tmp/goss" /bin/goss

if [ ! -f "/bin/goss" ]; then
    echo "ERROR: goss failed"
    exit 1
fi

chmod +x /bin/goss

echo "Cleanup"
rm -rf /tmp/goss.sha256
