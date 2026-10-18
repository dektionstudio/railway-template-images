#!/bin/sh
# EmDash on Railway. /data is the volume: the SQLite database and uploaded media.
set -e
if [ -z "$ADMIN_GATE_USER" ] || [ ${#ADMIN_GATE_PASSWORD} -lt 12 ]; then
  echo "[railway] ADMIN_GATE_USER and ADMIN_GATE_PASSWORD (12+ characters) must be set; not starting with the setup open to anyone"
  exit 1
fi
mkdir -p /data/uploads
chown node:node /data /data/uploads
if [ ! -f /data/.railway-volume ]; then
  date -u +%Y-%m-%dT%H:%M:%SZ > /data/.railway-volume
  echo "[railway] new data directory on the volume"
else
  echo "[railway] data directory on the volume since $(cat /data/.railway-volume)"
fi
ADMIN_GATE_HASH="$(caddy hash-password --plaintext "$ADMIN_GATE_PASSWORD")"
export ADMIN_GATE_HASH
echo "[railway] emdash $(node -p 'require("/app/node_modules/emdash/package.json").version') | node $(node --version)"
setpriv --reuid=node --regid=node --init-groups env HOME=/home/node caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
exec setpriv --reuid=node --regid=node --init-groups env HOME=/home/node HOST=127.0.0.1 PORT=4321 node ./dist/server/entry.mjs
