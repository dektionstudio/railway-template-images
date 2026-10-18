#!/bin/bash
# Odoo on Railway. /var/lib/odoo is the volume: attachments (the filestore) and sessions.
# The image's own entrypoint reads PORT as the database port, so this script writes the config itself.
set -e
for v in ODOO_ADMIN_EMAIL ODOO_ADMIN_PASSWORD ODOO_MASTER_PASSWORD PGHOST PGUSER PGPASSWORD; do
  if [ -z "${!v}" ]; then echo "[railway] $v must be set"; exit 1; fi
done
if [ ${#ODOO_MASTER_PASSWORD} -lt 24 ]; then echo "[railway] ODOO_MASTER_PASSWORD must be 24+ characters"; exit 1; fi
DB="${PGDATABASE:-odoo}"
export PGPORT="${PGPORT:-5432}" PGDATABASE="$DB"

# Railway mounts the volume as root; Odoo runs as the odoo user.
chown odoo:odoo /var/lib/odoo
if [ ! -f /var/lib/odoo/.railway-volume ]; then
  date -u +%Y-%m-%dT%H:%M:%SZ > /var/lib/odoo/.railway-volume
  chown -R odoo:odoo /var/lib/odoo
fi

CONF=/etc/odoo/railway.conf
cat > "$CONF" <<CONF
[options]
addons_path = /mnt/extra-addons
data_dir = /var/lib/odoo
db_host = $PGHOST
db_port = $PGPORT
db_user = $PGUSER
db_password = $PGPASSWORD
db_name = $DB
dbfilter = ^$DB\$
list_db = False
admin_passwd = $ODOO_MASTER_PASSWORD
proxy_mode = True
http_interface = 0.0.0.0
http_port = ${PORT:-8069}
workers = 0
max_cron_threads = 1
CONF
chown odoo:odoo "$CONF"
chmod 600 "$CONF"
as_odoo() { setpriv --reuid=odoo --regid=odoo --init-groups env HOME=/var/lib/odoo "$@"; }

i=0
until pg_isready -q; do
  i=$((i + 1)); [ $i -gt 60 ] && { echo "[railway] Postgres at $PGHOST:$PGPORT isn't answering"; exit 1; }
  sleep 2
done

# A new database is set up before the web server starts, so nobody can reach Odoo's default admin/admin login.
if [ "$(psql -tAc "select count(*) from pg_tables where tablename = 'ir_module_module'")" != "1" ]; then
  echo "[railway] new database $DB: installing Odoo's base module"
  as_odoo odoo -c "$CONF" -i base --stop-after-init --no-http
  as_odoo odoo shell -c "$CONF" --no-http --log-level=warn <<'PY'
import os
admin = env.ref("base.user_admin")
admin.write({"login": os.environ["ODOO_ADMIN_EMAIL"], "email": os.environ["ODOO_ADMIN_EMAIL"], "password": os.environ["ODOO_ADMIN_PASSWORD"]})
env.cr.commit()
print("[railway] admin login set to", admin.login)
PY
else
  echo "[railway] database $DB already set up (on the volume since $(cat /var/lib/odoo/.railway-volume))"
fi
echo "[railway] $(odoo --version)"
exec setpriv --reuid=odoo --regid=odoo --init-groups env HOME=/var/lib/odoo odoo -c "$CONF"
