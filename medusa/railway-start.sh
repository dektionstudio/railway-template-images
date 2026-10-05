#!/bin/sh
# Medusa on Railway, run from the built server (apps/backend/.medusa/server):
# 1. migrations (safe to repeat; on an empty database they also seed the starter store)
# 2. the first admin from MEDUSA_ADMIN_EMAIL / MEDUSA_ADMIN_PASSWORD (Medusa has no public admin sign-up)
# 3. the publishable key set to MEDUSA_PUBLISHABLE_KEY, which the storefront was built with
# 4. medusa start
set -e
cd /app/apps/backend/.medusa/server
MEDUSA=/app/apps/backend/node_modules/.bin/medusa

"$MEDUSA" db:migrate

if [ -n "$MEDUSA_ADMIN_EMAIL" ] && [ -n "$MEDUSA_ADMIN_PASSWORD" ]; then
  if "$MEDUSA" user -e "$MEDUSA_ADMIN_EMAIL" -p "$MEDUSA_ADMIN_PASSWORD" > /tmp/medusa-user.log 2>&1; then
    echo "[railway] admin account created for $MEDUSA_ADMIN_EMAIL"
  elif grep -qi "already exists" /tmp/medusa-user.log; then
    echo "[railway] admin account already exists"
  else
    echo "[railway] could not create the admin account:"
    tail -5 /tmp/medusa-user.log
  fi
fi

"$MEDUSA" exec ./src/scripts/railway-setup.js

exec "$MEDUSA" start
