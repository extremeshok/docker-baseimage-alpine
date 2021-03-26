#!/bin/bash

STATUS=0

# init shell scripts (ending in .sh) in /etc/init.d directory

# When init.d scripts fail (exit non-zero), container run will fail
# NOTE: exit with 99, this is the stop signal, container will exit cleanly

if ls /etc/init.d/*.sh &>/dev/null ; then
  for file in /etc/init.d/*.sh; do

    echo "[init] executing ${file}"

    /bin/bash -e $file

    STATUS=$?  # Captures exit code from script that was run

    if [[ $STATUS == $SIGNAL_BUILD_STOP ]] ; then
      echo "[init] exit signalled - ${file}"
      exit $STATUS
    fi

    if [[ $STATUS != 0 ]] ; then
      echo "[init] failed executing - ${file}"
      exit $STATUS
    fi
  done
else
  echo "[init] /etc/init.d/ empty"
  echo "[init] loading fallback /init"
  exit $STATUS
fi
