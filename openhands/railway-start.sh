#!/bin/sh
# OpenHands Agent Canvas on Railway. /home/openhands is the volume: settings, secrets, conversations,
# CLI logins and projects (/projects points into it) survive redeploys.
set -e
if [ ${#LOCAL_BACKEND_API_KEY} -lt 24 ]; then
  echo "[railway] LOCAL_BACKEND_API_KEY must be set (24+ characters); not starting an agent server without a key"
  exit 1
fi
# Railway mounts the volume as root; the image runs as openhands.
chown openhands:openhands /home/openhands
if [ ! -f /home/openhands/.railway-home ]; then
  cp -rn /etc/skel/. /home/openhands/ 2>/dev/null || true
  mkdir -p /home/openhands/.openhands /home/openhands/projects
  date -u +%Y-%m-%dT%H:%M:%SZ > /home/openhands/.railway-home
  chown -R openhands:openhands /home/openhands
  echo "[railway] new home directory on the volume"
else
  echo "[railway] home directory on the volume since $(cat /home/openhands/.railway-home)"
fi
# The image expects projects at /projects; keep them on the volume.
if [ ! -L /projects ]; then
  rm -rf /projects
  ln -s /home/openhands/projects /projects
fi
echo "[railway] node $(node --version) | claude $(claude --version 2>/dev/null | head -1) | codex $(codex --version 2>/dev/null | head -1)"
exec setpriv --reuid=openhands --regid=openhands --init-groups env HOME=/home/openhands USER=openhands \
  tini -- /opt/agent-canvas/entrypoint.sh
