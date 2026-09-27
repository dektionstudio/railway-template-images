#!/bin/sh
# Hash SEARXNG_PASSWORD for Caddy's basic auth, then start Caddy.
if [ ${#SEARXNG_PASSWORD} -lt 8 ]; then
  echo "[railway] SEARXNG_PASSWORD is missing or shorter than 8 characters; refusing to start an open instance"
  exit 1
fi
SEARXNG_PASSWORD_HASH=$(caddy hash-password --plaintext "$SEARXNG_PASSWORD")
export SEARXNG_PASSWORD_HASH
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
