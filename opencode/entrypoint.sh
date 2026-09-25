#!/bin/bash
# Runs OpenCode's web UI as the dev user, with the volume as home and ~/projects as the workspace.
set -eu
: "${OPENCODE_SERVER_PASSWORD:?OPENCODE_SERVER_PASSWORD is required}"
PORT="${PORT:-4096}"
H=/home/dev

# Railway mounts the volume owned by root and empty on first boot.
chown dev:dev "$H"
mkdir -p "$H/projects" && chown dev:dev "$H/projects"
if [ -n "${GIT_USER_NAME:-}" ]; then runuser -u dev -- env HOME="$H" git config --global user.name "$GIT_USER_NAME"; fi
if [ -n "${GIT_USER_EMAIL:-}" ]; then runuser -u dev -- env HOME="$H" git config --global user.email "$GIT_USER_EMAIL"; fi

cd "$H/projects"
exec runuser -u dev -- env HOME="$H" USER=dev LOGNAME=dev SHELL=/bin/bash \
  opencode web --hostname 0.0.0.0 --port "$PORT"
