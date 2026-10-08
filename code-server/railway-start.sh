#!/bin/sh
# code-server on Railway. /home/coder is the volume: extensions, settings, logins and projects survive redeploys.
set -e
if [ ${#PASSWORD} -lt 12 ]; then
  echo "[railway] PASSWORD must be set (12+ characters); not starting an editor without a login"
  exit 1
fi
chown coder:coder /home/coder
if [ ! -f /home/coder/.railway-home ]; then
  cp -rn /etc/skel/. /home/coder/ 2>/dev/null || true
  mkdir -p /home/coder/project
  date -u +%Y-%m-%dT%H:%M:%SZ > /home/coder/.railway-home
  chown -R coder:coder /home/coder
  echo "[railway] new home directory on the volume"
else
  echo "[railway] home directory on the volume since $(cat /home/coder/.railway-home)"
fi
echo "[railway] node $(node --version) | claude $(claude --version 2>/dev/null | head -1) | codex $(codex --version 2>/dev/null | head -1)"
exec setpriv --reuid=coder --regid=coder --init-groups env HOME=/home/coder USER=coder \
  code-server --bind-addr "0.0.0.0:${PORT:-8080}" --auth password --disable-telemetry --disable-update-check /home/coder/project
