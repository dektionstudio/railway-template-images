#!/bin/sh
# CloudCLI on Railway. /home/node is the volume: the CloudCLI account database, Claude Code / Codex / OpenCode
# logins and sessions, and your projects survive redeploys.
set -e
H=/home/node
if [ ${#CLOUDCLI_PASSWORD} -lt 12 ]; then
  echo "[railway] CLOUDCLI_PASSWORD must be set (12+ characters); not starting without a login"
  exit 1
fi
# Railway mounts the volume as root; CloudCLI and the agents run as the node user.
chown node:node "$H"
if [ ! -f "$H/.railway-home" ]; then
  cp -rn /etc/skel/. "$H/" 2>/dev/null || true
  mkdir -p "$H/projects" "$H/.cloudcli"
  date -u +%Y-%m-%dT%H:%M:%SZ > "$H/.railway-home"
  chown -R node:node "$H"
  echo "[railway] new home directory on the volume"
else
  echo "[railway] home directory on the volume since $(cat "$H/.railway-home")"
fi
export SERVER_PORT="${PORT:-3001}" DATABASE_PATH="$H/.cloudcli/auth.db"

# CloudCLI is single-user and lets the first visitor create the account. Create it from CLOUDCLI_USERNAME /
# CLOUDCLI_PASSWORD on localhost first, so the public port never serves an unclaimed instance.
if [ ! -f "$H/.cloudcli/.railway-account" ]; then
  setpriv --reuid=node --regid=node --init-groups env HOME="$H" USER=node HOST=127.0.0.1 cloudcli start > /tmp/cloudcli-setup.log 2>&1 &
  pid=$!
  i=0
  until curl -fs "http://127.0.0.1:$SERVER_PORT/health" > /dev/null; do
    i=$((i + 1)); [ $i -gt 90 ] && { echo "[railway] CloudCLI didn't start:"; tail -20 /tmp/cloudcli-setup.log; exit 1; }
    sleep 1
  done
  if curl -fs "http://127.0.0.1:$SERVER_PORT/api/auth/status" | grep -q '"needsSetup":true'; then
    node -e 'process.stdout.write(JSON.stringify({ username: process.env.CLOUDCLI_USERNAME || "admin", password: process.env.CLOUDCLI_PASSWORD }))' \
      | curl -fs -X POST -H "Content-Type: application/json" --data-binary @- "http://127.0.0.1:$SERVER_PORT/api/auth/register" > /dev/null
    echo "[railway] account ${CLOUDCLI_USERNAME:-admin} created"
  else
    echo "[railway] an account already exists"
  fi
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  # the public instance needs the port
  i=0
  while curl -fs "http://127.0.0.1:$SERVER_PORT/health" > /dev/null && [ $i -lt 30 ]; do i=$((i + 1)); sleep 1; done
  touch "$H/.cloudcli/.railway-account" && chown node:node "$H/.cloudcli/.railway-account"
fi
echo "[railway] cloudcli $(cloudcli version 2>/dev/null | grep -o '[0-9][0-9.]*' | head -1) | node $(node --version) | claude $(claude --version 2>/dev/null | head -1) | codex $(codex --version 2>/dev/null | head -1) | opencode $(opencode --version 2>/dev/null | head -1)"
exec setpriv --reuid=node --regid=node --init-groups env HOME="$H" USER=node HOST=0.0.0.0 cloudcli start
