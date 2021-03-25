FROM alpine:latest AS BUILD

LABEL mantainer="Adrian Kriel <admin@extremeshok.com>" vendor="eXtremeSHOK.com"

### Stage 1 - build ###

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

# add install files
COPY build/ /build

RUN echo "**** import justcontainers key ****" \
  && curl -L https://keybase.io/justcontainers/key.asc | gpg --no-tty --batch --import --quiet

# S6 for zombie reaping, boot-time coordination, signal transformation/distribution
# https://github.com/just-containers/s6-overlay
RUN echo "**** install s6 overlay ****" \
  && /bin/bash -e /build/install-s6.sh

# Addon for S6 to add a small syslog replacement
RUN echo "**** install socklog overlay ****" \
  && /bin/bash -e /build/install-socklog.sh

# GOSS for serverspec-like testing
RUN echo "**** install goss ****" \
  && /bin/bash -e /build/install-goss.sh

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
  && rm -rf /tmp/* \
  && rm -rf /build

# add local files
COPY rootfs/ /

RUN chmod 755 /sbin/apk-install

FROM scratch
COPY --from=BASE / .

ENTRYPOINT ["/init"]
