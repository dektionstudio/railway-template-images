#!/bin/sh
# Writes $APP_DIR/config.json on every start: dashboard login, a key required on every model call, one virtual
# key that can use every provider, browser access (CORS) limited to the public domain, and a provider entry for
# each provider key set as a variable. Secrets stay in variables: the file only holds env.NAME references.
# Bifrost reconciles the file into its SQLite store at start ("split" mode), so changes made in the dashboard
# stay unless the matching part of this file changes.
set -e
if [ ${#BIFROST_ADMIN_PASSWORD} -lt 12 ] || [ ${#BIFROST_VIRTUAL_KEY} -lt 20 ]; then
  echo "[railway] BIFROST_ADMIN_PASSWORD (12+ characters) and BIFROST_VIRTUAL_KEY must be set; not starting an open gateway"
  exit 1
fi
APP_DIR=${APP_DIR:-/app/data}
mkdir -p "$APP_DIR"

origins=""
for o in $(echo "${BIFROST_ALLOWED_ORIGINS:-https://$RAILWAY_PUBLIC_DOMAIN}" | tr ',' ' '); do
  origins="${origins:+$origins, }\"$o\""
done

providers=""
names=""
add() { # add <bifrost provider> <variable holding its key>
  eval "val=\${$2:-}"
  [ -n "$val" ] || return 0
  names="$names $1"
  providers="${providers:+$providers,
    }\"$1\": { \"keys\": [{ \"id\": \"railway-$1\", \"name\": \"$2 variable\", \"value\": \"env.$2\", \"weight\": 1, \"models\": [\"*\"] }] }"
}
add openai OPENAI_API_KEY
add anthropic ANTHROPIC_API_KEY
add gemini GEMINI_API_KEY
add openrouter OPENROUTER_API_KEY
add groq GROQ_API_KEY
add mistral MISTRAL_API_KEY
add deepseek DEEPSEEK_API_KEY
add xai XAI_API_KEY

{
  echo '{'
  echo '  "$schema": "https://www.getbifrost.ai/schema",'
  echo "  \"client\": { \"enforce_auth_on_inference\": true, \"allowed_origins\": [$origins], \"enable_logging\": true, \"log_retention_days\": 30 },"
  echo '  "governance": {'
  echo '    "auth_config": { "is_enabled": true, "admin_username": "env.BIFROST_ADMIN_USERNAME", "admin_password": "env.BIFROST_ADMIN_PASSWORD" },'
  echo '    "virtual_keys": [{ "id": "railway-default", "name": "Default key (created at deploy)", "value": "env.BIFROST_VIRTUAL_KEY", "is_active": true, "allow_all_providers": true }]'
  if [ -n "$providers" ]; then
    echo '  },'
    echo "  \"providers\": {
    $providers
  }"
  else
    echo '  }'
  fi
  echo '}'
} > "$APP_DIR/config.json"
echo "[railway] wrote $APP_DIR/config.json: dashboard login on, key required on every model call, providers from variables:${names:- none (add them in the dashboard)}"

exec /app/docker-entrypoint.sh /app/main
