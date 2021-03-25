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

curl -L https://keybase.io/justcontainers/key.asc | gpg --no-tty --batch --import --quiet

S6_VERSION="$(curl -L --silent "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
echo "Version: ${S6_VERSION}"
curl -L --silent -o /tmp/s6-overlay.tar.gz "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${ARCHITECTURE}.tar.gz"
curl -L --silent -o /tmp/s6-overlay.sig "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${ARCHITECTURE}.tar.gz.sig"
gpg --no-tty --batch --verify --quiet /tmp/s6-overlay.sig /tmp/s6-overlay.tar.gz 2> /dev/null
tar xfz /tmp/s6-overlay.tar.gz -C /

if [ ! -f "/bin/s6-svscan" ]; then
    echo "ERROR: S6 failed"
    exit 1
fi

echo "Cleanup"
rm -f /tmp/s6-overlay.tar.gz
rm -f /tmp/s6-overlay.tar.gz.sig
