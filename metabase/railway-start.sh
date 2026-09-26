#!/bin/bash
# Start Metabase the way the image does, complete the first-run setup in the background, pass stop signals on.
/app/run_metabase.sh "$@" &
pid=$!
trap 'kill -TERM "$pid" 2>/dev/null' TERM INT
if [ -n "${MB_ADMIN_EMAIL:-}" ] && [ -n "${MB_ADMIN_PASSWORD:-}" ]; then
  /usr/local/bin/railway-claim.sh &
fi
wait "$pid"
