#!/bin/sh
# Start Activepieces the way the image does, claim the owner account in the background, and pass stop
# signals on to it.
cd /usr/src/app
./docker-entrypoint.sh &
pid=$!
trap 'kill -TERM "$pid" 2>/dev/null' TERM INT
if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
  node /usr/local/bin/railway-claim.mjs &
fi
wait "$pid"
