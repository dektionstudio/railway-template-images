#!/bin/bash
# Complete Metabase's first-run setup from MB_ADMIN_EMAIL / MB_ADMIN_PASSWORD. Metabase exposes a one-time
# setup token until an admin exists; once setup is done this does nothing.
log() { echo "[railway-claim] $*"; }
base="http://127.0.0.1:${MB_JETTY_PORT:-3000}"

for _ in $(seq 1 200); do
  curl -fs "$base/api/health" >/dev/null 2>&1 && break
  sleep 3
done
props=$(curl -fs "$base/api/session/properties")
if [ -z "$props" ]; then log "Metabase didn't answer; complete the setup in the browser instead"; exit 0; fi
if echo "$props" | grep -q '"has-user-setup":true'; then log "Metabase is already set up"; exit 0; fi
token=$(echo "$props" | grep -o '"setup-token":"[^"]*"' | cut -d'"' -f4)
if [ -z "$token" ]; then log "no setup token found; complete the setup in the browser"; exit 0; fi

site="${MB_SITE_NAME:-Metabase}"
body=$(printf '{"token":"%s","user":{"email":"%s","first_name":"%s","last_name":"%s","password":"%s","site_name":"%s"},"prefs":{"site_name":"%s","site_locale":"en","allow_tracking":false}}' \
  "$token" "$MB_ADMIN_EMAIL" "${MB_ADMIN_FIRST_NAME:-Admin}" "${MB_ADMIN_LAST_NAME:-User}" "$MB_ADMIN_PASSWORD" "$site" "$site")
code=$(curl -s -o /tmp/railway-setup.out -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$body" "$base/api/setup")
if [ "$code" = "200" ]; then log "admin account created for $MB_ADMIN_EMAIL"; else log "setup returned HTTP $code: $(head -c 200 /tmp/railway-setup.out)"; fi
rm -f /tmp/railway-setup.out
