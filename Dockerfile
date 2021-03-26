FROM alpine:latest AS build

LABEL mantainer="Adrian Kriel <admin@extremeshok.com>" vendor="eXtremeSHOK.com"

### Stage - build ###

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

RUN echo "**** setting permissions ****" \
  && chmod 0755 /sbin/apk-install \
  && chmod 0755 /usr/bin/with-bigcontenv \
  && chmod 0755 /start.sh \
  && chmod 0755 /init.sh

### Stage - Merge ###

FROM scratch
COPY --from=build / .

# Used when an init process requests the container to gracefully exit, uses supervisor to maintain long-running processes
ENV SIGNAL_BUILD_STOP=99
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KILL_FINISH_MAXTIME=10000
ENV S6_KILL_GRACETIME=6000

RUN goss -g /etc/goss/baseimage.yaml validate

# NOT using s6 init as the entrypoint
#ENTRYPOINT ["/init"]

CMD ["/bin/bash", "/start.sh"]
