#!/bin/ash
# Runs after the image's entrypoint (database wait, migrations, cron). Creates the first admin when the panel
# has no users yet, then starts nginx, php-fpm and the queue worker under supervisord like the image does.
cd /app
if [ -n "$PTERODACTYL_ADMIN_EMAIL" ] && [ -n "$PTERODACTYL_ADMIN_PASSWORD" ]; then
  users=$(php artisan tinker --execute='echo "USERS=".\Pterodactyl\Models\User::count();' 2>/dev/null | sed -n 's/.*USERS=\([0-9][0-9]*\).*/\1/p' | tail -1)
  if [ "$users" = "0" ]; then
    if php artisan p:user:make --email="$PTERODACTYL_ADMIN_EMAIL" --username="${PTERODACTYL_ADMIN_USERNAME:-admin}" \
      --name-first=Admin --name-last=User --password="$PTERODACTYL_ADMIN_PASSWORD" --admin=1 --no-interaction >/dev/null 2>&1; then
      echo "[railway] admin account created for $PTERODACTYL_ADMIN_EMAIL"
    else
      echo "[railway] could not create the admin account; run php artisan p:user:make in the service shell"
    fi
  elif [ -n "$users" ]; then
    echo "[railway] the panel already has users"
  else
    echo "[railway] could not read the user count (database not ready?); skipping the admin account"
  fi
fi
exec supervisord -n -c /etc/supervisord.conf
