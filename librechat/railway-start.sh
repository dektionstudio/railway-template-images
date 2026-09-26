#!/bin/sh
# Runs as root to prepare the volume, then starts LibreChat as the image's node user.
set -e
cd /app

# Uploads, generated images and logs go on the volume. The image keeps them under /app, so link those paths
# (copying anything the image ships there on first start).
DATA="${LIBRECHAT_DATA_DIR:-/data}"
for pair in uploads:/app/uploads images:/app/client/public/images logs:/app/logs; do
  src="$DATA/${pair%%:*}"
  dst="${pair#*:}"
  mkdir -p "$src"
  if [ ! -L "$dst" ]; then
    if [ -d "$dst" ]; then cp -an "$dst/." "$src/" 2>/dev/null || true; rm -rf "$dst"; fi
    ln -s "$src" "$dst"
  fi
done
chown -R node:node "$DATA"

# librechat.yaml: an OpenRouter endpoint that uses OPENROUTER_KEY when it's set on the service and asks each
# user for a key otherwise. A CONFIG_PATH you set yourself wins.
if [ -z "${CONFIG_PATH:-}" ]; then
  key='user_provided'
  [ -n "${OPENROUTER_KEY:-}" ] && key='${OPENROUTER_KEY}'
  cat > /app/librechat.railway.yaml <<EOF
version: 1.3.13
cache: true
endpoints:
  custom:
    - name: "OpenRouter"
      apiKey: "$key"
      baseURL: "https://openrouter.ai/api/v1"
      models:
        default: ["openai/gpt-4o-mini", "anthropic/claude-sonnet-4.5", "google/gemini-2.5-flash"]
        fetch: true
      titleConvo: true
      titleModel: "openai/gpt-4o-mini"
      dropParams: ["stop"]
      modelDisplayLabel: "OpenRouter"
EOF
  chown node:node /app/librechat.railway.yaml
  export CONFIG_PATH=/app/librechat.railway.yaml
fi

# First admin. LibreChat's create-user script registers through the normal path, so the first account gets
# the admin role; on later starts it reports that the user exists and nothing changes. MongoDB may still be
# starting, hence the retries.
if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
  for i in 1 2 3 4 5 6 7 8 9 10; do
    out=$(su-exec node node config/create-user.js "$ADMIN_EMAIL" "${ADMIN_NAME:-Admin}" "${ADMIN_USERNAME:-admin}" "$ADMIN_PASSWORD" --email-verified=true </dev/null 2>&1) && { echo "[railway-start] admin account created for $ADMIN_EMAIL"; break; }
    case "$out" in
      *"already exists"*) echo "[railway-start] admin account already exists"; break ;;
    esac
    [ "$i" = 10 ] && echo "[railway-start] could not create the admin account: $(echo "$out" | grep -v -i password | tail -n 3)"
    sleep 5
  done
fi

exec su-exec node npm run backend
