#!/bin/bash
# Archon on Railway. /.archon is the volume (workspaces, worktrees, artifacts); conversations, runs and users are
# in Postgres. The image's own entrypoint fixes the volume's ownership and drops to appuser.
set -e
for v in ARCHON_ADMIN_EMAIL ARCHON_ADMIN_PASSWORD BETTER_AUTH_SECRET DATABASE_URL; do
  if [ -z "${!v}" ]; then echo "[railway] $v must be set; not starting Archon without its login"; exit 1; fi
done
if [ ${#ARCHON_ADMIN_PASSWORD} -lt 12 ]; then echo "[railway] ARCHON_ADMIN_PASSWORD must be 12+ characters"; exit 1; fi
if [ ${#BETTER_AUTH_SECRET} -lt 32 ]; then echo "[railway] BETTER_AUTH_SECRET must be 32+ characters"; exit 1; fi
mkdir -p /.archon

# Archon's login lets the allowlisted email sign up. Create that account first, with Archon listening on
# localhost only, so the public URL never serves an unclaimed login.
if [ ! -f /.archon/.railway-owner ]; then
  SETUP_PORT=3999
  # its own process group, so stopping it also stops the server child that `bun run` starts
  setsid env HOST=127.0.0.1 PORT=$SETUP_PORT docker-entrypoint.sh > /tmp/archon-setup.log 2>&1 &
  pid=$!
  i=0
  until curl -fs "http://127.0.0.1:$SETUP_PORT/api/health" > /dev/null; do
    i=$((i + 1)); if [ $i -gt 120 ]; then echo "[railway] Archon didn't start:"; tail -30 /tmp/archon-setup.log; exit 1; fi
    sleep 1
  done
  body=$(node -e 'process.stdout.write(JSON.stringify({ email: process.env.ARCHON_ADMIN_EMAIL, password: process.env.ARCHON_ADMIN_PASSWORD, name: process.env.ARCHON_ADMIN_NAME || "Owner" }))' 2>/dev/null \
    || bun -e 'process.stdout.write(JSON.stringify({ email: process.env.ARCHON_ADMIN_EMAIL, password: process.env.ARCHON_ADMIN_PASSWORD, name: process.env.ARCHON_ADMIN_NAME || "Owner" }))')
  code=$(curl -s -o /tmp/archon-signup.json -w "%{http_code}" -X POST "http://127.0.0.1:$SETUP_PORT/api/auth/sign-up/email" \
    -H "Content-Type: application/json" -H "Origin: http://127.0.0.1:$SETUP_PORT" --data-binary "$body")
  if [ "$code" = "200" ]; then
    echo "[railway] owner account created for ARCHON_ADMIN_EMAIL"
  elif grep -qi "exist" /tmp/archon-signup.json; then
    echo "[railway] owner account already exists"
  else
    echo "[railway] creating the owner account failed ($code):"; head -c 400 /tmp/archon-signup.json; echo; kill -- -"$pid" 2>/dev/null || true; exit 1
  fi
  kill -- -"$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  i=0; while curl -fs "http://127.0.0.1:$SETUP_PORT/api/health" > /dev/null && [ $i -lt 30 ]; do i=$((i + 1)); sleep 1; done
  date -u +%Y-%m-%dT%H:%M:%SZ > /.archon/.railway-owner
else
  echo "[railway] owner account set up on $(cat /.archon/.railway-owner)"
fi
exec env HOST=0.0.0.0 docker-entrypoint.sh
