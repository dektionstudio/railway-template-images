#!/bin/sh
# Doory on Railway. /app/media is the volume: uploads, the element library, fonts and templates.
set -e
for v in DJANGO_SECRET_KEY SITE_URL DATABASE_URL DOORY_ADMIN_EMAIL DOORY_ADMIN_PASSWORD; do
  eval "val=\${$v:-}"
  if [ -z "$val" ]; then echo "[railway] $v must be set"; exit 1; fi
done
if [ ${#DOORY_ADMIN_PASSWORD} -lt 12 ]; then echo "[railway] DOORY_ADMIN_PASSWORD must be 12+ characters"; exit 1; fi

# Railway mounts the volume as root; the backend runs as the doory user, nginx's workers read the files.
chown doory:doory /app/media
if [ ! -f /app/media/.railway-volume ]; then
  date -u +%Y-%m-%dT%H:%M:%SZ > /app/media/.railway-volume
  echo "[railway] new media folder on the volume"
else
  echo "[railway] media folder on the volume since $(cat /app/media/.railway-volume)"
fi

sed -i "s|listen [0-9]* default_server;|listen ${PORT:-8080} default_server;\n    listen [::]:${PORT:-8080} default_server;|" /etc/nginx/conf.d/doory.conf
grep -q "listen \[::\]:${PORT:-8080}" /etc/nginx/conf.d/doory.conf || sed -i "s|listen ${PORT:-8080} default_server;|listen ${PORT:-8080} default_server;\n    listen [::]:${PORT:-8080} default_server;|" /etc/nginx/conf.d/doory.conf
nginx -t -q && nginx

as_doory() { setpriv --reuid=doory --regid=doory --init-groups env HOME=/app "$@"; }
# Upstream's entrypoint runs its preparation (migrations, static files, the content syncs) only for gunicorn;
# `gunicorn --version` runs exactly that preparation and then exits.
as_doory /app/docker-entrypoint.sh gunicorn --version
if DJANGO_SUPERUSER_EMAIL="$DOORY_ADMIN_EMAIL" DJANGO_SUPERUSER_PASSWORD="$DOORY_ADMIN_PASSWORD" \
   as_doory python manage.py createsuperuser --noinput > /tmp/superuser.log 2>&1; then
  echo "[railway] admin account created for DOORY_ADMIN_EMAIL"
elif grep -qi "already" /tmp/superuser.log; then
  echo "[railway] admin account already exists"
else
  cat /tmp/superuser.log; exit 1
fi
exec setpriv --reuid=doory --regid=doory --init-groups env HOME=/app /app/docker-entrypoint.sh \
  uvicorn doory.asgi:application --host 127.0.0.1 --port 8000 --workers 1 --ws auto --ws-max-size 2097152 \
  --lifespan off --no-server-header --proxy-headers --forwarded-allow-ips 127.0.0.1 --timeout-graceful-shutdown 20
