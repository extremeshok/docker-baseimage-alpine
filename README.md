# eXtremeSHOK optimized base image

# Built with the latest versions of :
+ [Alpine linux](https://alpinelinux.org/)
+ [S6 overlay](https://github.com/just-containers/s6-overlay)
+ [socklog overlay](https://github.com/just-containers/socklog-overlay)

# Alpine linux
A security-oriented, lightweight Linux distribution based on musl libc and busybox.

# S6 overlay
A process supervisor (aka replaces supervisor.d and tini), chosen over tini (exec --init) as it can manage multiple processes.

# socklog overlay
A small syslog add-on for s6-overlay which replaces syslogd.

### NOTES:

#### latest versions:
The latest versions are automatically detected and used, so image is always the latest.

#### tini : https://github.com/krallin/tini
+ All tini does is spawn a single child (tini is meant to be run in a container), and wait for it to exit all the while reaping zombies and performing signal forwarding.
