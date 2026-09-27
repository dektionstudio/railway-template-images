#!/bin/ash
# Runs after the image's entrypoint (database wait, migrations, cron). Creates the first admin when the panel
# has no users yet, then starts nginx, php-fpm and the queue worker under supervisord like the image does.
cd /app
if [ -n "$PTERODACTYL_ADMIN_EMAIL" ] && [ -n "$PTERODACTYL_ADMIN_PASSWORD" ]; then
  users=$(php artisan tinker --execute='echo \Pterodactyl\Models\User::count();' 2>/dev/null | tr -dc '0-9')
  if [ "$users" = "0" ]; then
    if php artisan p:user:make --email="$PTERODACTYL_ADMIN_EMAIL" --username="${PTERODACTYL_ADMIN_USERNAME:-admin}" \
      --name-first=Admin --name-last=User --password="$PTERODACTYL_ADMIN_PASSWORD" --admin=1 --no-interaction >/dev/null 2>&1; then
      echo "[railway] admin account created for $PTERODACTYL_ADMIN_EMAIL"
    else
      echo "[railway] could not create the admin account; run php artisan p:user:make in the service shell"
    fi
  else
    echo "[railway] the panel already has users"
  fi
fi
exec supervisord -n -c /etc/supervisord.conf
