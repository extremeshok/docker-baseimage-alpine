FROM alpine:3.11 AS BUILD

LABEL mantainer="Adrian Kriel <admin@extremeshok.com>" vendor="eXtremeSHOK.com"

# build time varbiles
ARG OVERLAY_ARCH="amd64"

# environment variables
ENV PS1="[$(whoami)@$(hostname):$(pwd)]$ "
#ENV PS1 "\h:\W \u$ "
ENV HOME="/root"
ENV TERM="xterm"

RUN \
  echo "**** install build packages ****" \
  && apk add --update --no-cache --virtual=build-dependencies \
    ca-certificates \
    curl \
    tar

RUN \
  echo "**** install packages ****" \
  && apk add --update --no-cache \
  shadow

RUN \
  echo "**** install s6 overlay ****" \
  && S6VERSION="$(curl --silent "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')" \
  && echo "$S6VERSION" \
  && curl --silent -o /tmp/s6-overlay.tar.gz -L \
   "https://github.com/just-containers/s6-overlay/releases/download/${S6VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
  && tar xfz /tmp/s6-overlay.tar.gz -C / \
  && rm -f /tmp/s6-overlay.tar.gz

RUN \
  echo "**** install socklog overlay ****" \
  && SOCKLOGVERSION="$(curl --silent "https://api.github.com/repos/just-containers/socklog-overlay/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')" \
  && echo "$SOCKLOGVERSION" \
  && curl --silent -o /tmp/socklog-overlay.tar.gz -L \
   "https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOGVERSION}/socklog-overlay-${OVERLAY_ARCH}.tar.gz" \
  && tar xfz /tmp/socklog-overlay.tar.gz -C / \
  && rm -f /tmp/socklog-overlay.tar.gz

RUN \
  echo "**** create xs user and make our folders ****" \
  && addgroup -g 911 -S xs \
  && adduser -u 911 -S -D -G xs -h /config -s /bin/false xs \
  && adduser xs users \
  && mkdir -p \
    /app \
    /config \S6VERSION \
    /defaults

RUN \
  echo "**** cleanup ****" \
  && apk del --purge build-dependencies \
  && rm -rf /tmp/*

# add local files
COPY rootfs/ /

RUN chmod 755 /sbin/apk-install

ENTRYPOINT ["/init"]
