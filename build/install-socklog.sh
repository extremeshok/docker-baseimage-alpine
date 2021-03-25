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

SOCKLOG_VERSION="$(curl --silent "https://api.github.com/repos/just-containers/socklog-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
echo "Version: ${SOCKLOG_VERSION}"
curl -L --silent -o /tmp/socklog-overlay.tar.gz "https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG_VERSION}/socklog-overlay-${ARCHITECTURE}.tar.gz"
curl -L --silent -o /tmp/socklog-overlay.sig "https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG_VERSION}/socklog-overlay-${ARCHITECTURE}.tar.gz.sig"
gpg --no-tty --batch --verify --quiet /tmp/socklog-overlay.sig /tmp/socklog-overlay.tar.gz 2> /dev/null
tar xfz /tmp/socklog-overlay.tar.gz -C /

if [ ! -f "/bin/s6-svscan" ]; then
    echo "ERROR: S6 failed"
    exit 1
fi

echo "Cleanup"
rm -f /tmp/socklog-overlay.tar.gz
rm -f /tmp/socklog-overlay.tar.gz.sig
