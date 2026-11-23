#!/bin/bash
# Start Ollama on port 11434 (private network and Caddy's upstream) and Caddy on $PORT (the public domain),
# pull the models in OLLAMA_PULL_MODELS, and stop when either process stops so Railway restarts the container.
if [ ${#OLLAMA_API_KEY} -lt 16 ]; then
  echo "[railway] OLLAMA_API_KEY is missing or shorter than 16 characters; refusing to start without authentication"
  exit 1
fi
# [::] is dual-stack: Railway's private network is IPv6, Caddy connects over 127.0.0.1.
export OLLAMA_HOST="[::]:11434"

/bin/ollama serve &
ollama_pid=$!
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid=$!
trap 'kill -TERM $ollama_pid $caddy_pid 2>/dev/null' TERM INT

for _ in $(seq 1 60); do /bin/ollama list >/dev/null 2>&1 && break; sleep 1; done
# ollama pull only downloads what's missing, so this is quick on later starts.
for model in $(echo "${OLLAMA_PULL_MODELS:-}" | tr ',' ' '); do
  if /bin/ollama pull "$model" >/dev/null 2>&1; then echo "[railway] model ready: $model"; else echo "[railway] could not pull $model"; fi
done

wait -n $ollama_pid $caddy_pid
kill -TERM $ollama_pid $caddy_pid 2>/dev/null
exit 1
