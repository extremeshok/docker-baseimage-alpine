#!/bin/bash

# Begin startup sequence
/bin/bash -e /init.sh

STATUS=$?  # Captures exit code from script that was run

if [[ $STATUS == $SIGNAL_BUILD_STOP ]] ; then
  echo "[start] container exit requested"
  exit # Exit cleanly
fi

if [[ $STATUS != 0 ]] ; then
  echo "[start] failed to init"
  exit $STATUS
fi

# Start process manager
echo "[start] starting process manager"
exec /init
