#!/bin/bash
# GBrain on Railway. /data is the volume: GBRAIN_HOME (config, locks, logs) and the brain's markdown in
# /data/brain, a git repo. Pages, links, embeddings and the job queue are in Postgres.
set -e
for v in GBRAIN_DATABASE_URL GBRAIN_ADMIN_BOOTSTRAP_TOKEN GBRAIN_PUBLIC_URL; do
  if [ -z "${!v}" ]; then echo "[railway] $v must be set"; exit 1; fi
done
if [ ${#GBRAIN_ADMIN_BOOTSTRAP_TOKEN} -lt 32 ]; then echo "[railway] GBRAIN_ADMIN_BOOTSTRAP_TOKEN must be 32+ characters"; exit 1; fi

export GBRAIN_HOME=/data HOME=/data
mkdir -p /data/brain
chown -R bun:bun /data
as_bun() { setpriv --reuid=bun --regid=bun --init-groups "$@"; }

cd /data
if [ ! -f /data/.gbrain/config.json ]; then
  echo "[railway] first start: setting up the brain on Postgres"
  as_bun git config --global user.name "GBrain"
  as_bun git config --global user.email "gbrain@localhost"
  # The embedding provider comes from whichever key is set (Voyage, OpenAI, OpenRouter); with none, search is
  # keyword-only until one is added.
  as_bun gbrain init --url "$GBRAIN_DATABASE_URL" --non-interactive --content-root /data/brain --git
fi
# Setup migrations on a new brain, schema migrations after an upgrade; a no-op when nothing is pending.
as_bun gbrain apply-migrations --yes --no-autopilot-install

# The worker drains the job queue (embedding, sync, subagent jobs). GBRAIN_AUTOPILOT=true runs autopilot
# instead, which brings its own worker and also runs the maintenance cycle (it spends model tokens).
(
  while true; do
    if [ "$GBRAIN_AUTOPILOT" = "true" ]; then as_bun gbrain autopilot --repo /data/brain; else as_bun gbrain jobs supervisor --concurrency 2; fi
    echo "[railway] worker exited; restarting in 10 s"
    sleep 10
  done
) &

exec setpriv --reuid=bun --regid=bun --init-groups gbrain serve --http --port "${PORT:-8080}" --bind 0.0.0.0 --public-url "$GBRAIN_PUBLIC_URL"
