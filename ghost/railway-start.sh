#!/bin/sh
# Start Ghost through the image's own entrypoint (it hands the content volume to the node user), claim the
# owner account in the background, and pass stop signals on.
docker-entrypoint.sh "$@" &
pid=$!
trap 'kill -TERM "$pid" 2>/dev/null' TERM INT
if [ -n "${GHOST_ADMIN_EMAIL:-}" ] && [ -n "${GHOST_ADMIN_PASSWORD:-}" ]; then
  node /usr/local/bin/railway-claim.mjs &
fi
wait "$pid"
