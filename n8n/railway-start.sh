#!/bin/sh
# Runs as root only to hand the Railway volume (n8n's folder: community nodes, binary data) to the node user,
# then starts n8n the way the image does and claims the owner account in the background.
mkdir -p /home/node/.n8n
chown -R node:node /home/node/.n8n
su-exec node /docker-entrypoint.sh &
pid=$!
trap 'kill -TERM "$pid" 2>/dev/null' TERM INT
if [ -n "${N8N_OWNER_EMAIL:-}" ] && [ -n "${N8N_OWNER_PASSWORD:-}" ]; then
  su-exec node node /usr/local/bin/railway-claim.mjs &
fi
wait "$pid"
