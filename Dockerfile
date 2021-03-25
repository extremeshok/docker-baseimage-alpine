FROM alpine:latest AS BUILD

LABEL mantainer="Adrian Kriel <admin@extremeshok.com>" vendor="eXtremeSHOK.com"

### Stage 1 - build ###

# build time varbiles
ARG OVERLAY_ARCH="amd64"

# environment variables
ENV PS1="[$(whoami)@$(hostname):$(pwd)]$ "
#ENV PS1 "\h:\W \u$ "
ENV HOME="/root"
ENV TERM="xterm"

RUN echo "**** install build packages ****" \
  && apk add --update --no-cache --virtual=build-dependencies \
    ca-certificates \
    gnupg \
    shadow \
    tar

RUN echo "**** install packages ****" \
  && apk add --update --no-cache \
  sed \
  grep \
  bash \
  curl

RUN echo "**** import justcontainers key ****" \
  && curl -L https://keybase.io/justcontainers/key.asc | gpg --no-tty --batch --import --quiet

# S6 for zombie reaping, boot-time coordination, signal transformation/distribution
# https://github.com/just-containers/s6-overlay
RUN echo "**** install s6 overlay ****" \
  && S6_VERSION="$(curl -L --silent "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')" \
  && echo "S6 version: $S6_VERSION" \
  && curl --silent -o /tmp/s6-overlay.tar.gz\
   "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
  && curl -L --silent -o /tmp/s6-overlay.sig \
   "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
  && gpg --no-tty --batch --verify --quiet /tmp/s6-overlay.sig s6-overlay.tar.gz 2> /dev/null \
  && tar xfz /tmp/s6-overlay.tar.gz -C / \
  && rm -f /tmp/s6-overlay.tar.gz \
  && rm -f /tmp/s6-overlay.tar.gz.sig

# Addon for S6 to add a small syslog replacement
RUN echo "**** install socklog overlay ****" \
  && SOCKLOG_VERSION="$(curl --silent "https://api.github.com/repos/just-containers/socklog-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')" \
  && echo "Socklog version: $SOCKLOG_VERSION" \
  && curl -L --silent -o /tmp/socklog-overlay.tar.gz \
   "https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG_VERSION}/socklog-overlay-${OVERLAY_ARCH}.tar.gz" \
  && curl -L --silent -o /tmp/socklog-overlay.sig \
   "https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG_VERSION}/socklog-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
  && gpg --no-tty --batch --verify --quiet /tmp/socklog-overlay.sig socklog-overlay.tar.gz 2> /dev/null \
  && tar xfz /tmp/socklog-overlay.tar.gz -C / \
  && rm -f /tmp/socklog-overlay.tar.gz \
  && rm -f /tmp/socklog-overlay.tar.gz.sig

# GOSS for serverspec-like testing
RUN echo "**** install goss ****" \
  GOSS_VERSION="$(curl --silent "https://api.github.com/repos/aelsabbahy/goss/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"  \
  && echo "Goss version: $GOSS_VERSION" \
  && curl -L --silent -o /tmp/goss-linux-${OVERLAY_ARCH} \
    "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${OVERLAY_ARCH}" \
  && curl -L --silent -o /tmp/goss.sha256 "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${OVERLAY_ARCH}.sha256" \
  && sha256sum -s -c /tmp/goss.sha256 \
  && mv -f /tmp/goss-linux-${OVERLAY_ARCH} /bin/goss \
  && chmod +x /bin/goss \
  && rm -rf /tmp/goss.sha256

RUN echo "**** Applying bug fixes ****" \
 # https://github.com/gliderlabs/docker-alpine/issues/11#issuecomment-106233554
  && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' > /etc/nsswitch.conf

RUN echo "**** create xs user and make our folders ****" \
  && addgroup -g 911 -S xs \
  && adduser -u 911 -S -D -G xs -h /config -s /bin/false xs \
  && adduser xs users \
  && mkdir -p /app \
  && mkdir -p /config \
  && mkdir -p /defaults

RUN echo "**** cleanup ****" \
  && apk del --purge build-dependencies \
  && rm -rf /tmp/* \
  && rm -rf /var/cache/apk/* \
  && rm -rf /var/tmp/* \
  && rm -rf /tmp/*

# add local files
COPY rootfs/ /

RUN chmod 755 /sbin/apk-install

FROM scratch
COPY --from=BASE / .

ENTRYPOINT ["/init"]
