#!/bin/sh
# Starts mtg in fake-TLS mode and prints the Telegram link for this deployment.
#   PROXY_SECRET     ee + 32 hex chars (the key) + the hex of the fronting domain
#   FAKE_TLS_DOMAIN  optional: switch the fronting domain and keep the key
#   PORT             where Railway's TCP proxy sends traffic (default 3128)
set -eu

port="${PORT:-3128}"
secret="${PROXY_SECRET:-}"
key=$(printf '%s' "$secret" | cut -c3-34)

case "$secret" in
  ee*) ;;
  *) echo "PROXY_SECRET must start with ee (a fake-TLS secret)." >&2; exit 1 ;;
esac
case "$key" in
  *[!0-9a-f]*) echo "PROXY_SECRET must be lowercase hex." >&2; exit 1 ;;
esac
if [ "${#key}" -ne 32 ]; then
  echo "PROXY_SECRET needs 32 hex characters after ee." >&2
  exit 1
fi

if [ -n "${FAKE_TLS_DOMAIN:-}" ]; then
  secret="ee${key}$(printf '%s' "$FAKE_TLS_DOMAIN" | od -An -tx1 | tr -d ' \n')"
  echo "Using fronting domain ${FAKE_TLS_DOMAIN}. The PROXY_LINK variable still has the old secret, use the link below."
fi

if [ -n "${RAILWAY_TCP_PROXY_DOMAIN:-}" ]; then
  echo "Telegram link: tg://proxy?server=${RAILWAY_TCP_PROXY_DOMAIN}&port=${RAILWAY_TCP_PROXY_PORT}&secret=${secret}"
  echo "Share link:    https://t.me/proxy?server=${RAILWAY_TCP_PROXY_DOMAIN}&port=${RAILWAY_TCP_PROXY_PORT}&secret=${secret}"
fi

# mtg prefers IPv6 by default; IPv4 is the safe choice for reaching Telegram's data centers from Railway.
exec mtg simple-run --prefer-ip prefer-ipv4 0.0.0.0:"$port" "$secret"
