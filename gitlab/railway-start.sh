#!/bin/bash
# GitLab CE on Railway. The volume is /var/opt/gitlab (repositories, the bundled Postgres and Redis, uploads).
# /etc/gitlab holds gitlab-secrets.json, the keys for CI/CD variables, 2FA and runner tokens: it lives on the same
# volume, because a fresh one on every restart would leave that data unreadable.
set -e
for v in GITLAB_ROOT_PASSWORD RAILWAY_PUBLIC_DOMAIN; do
  if [ -z "${!v}" ]; then echo "[railway] $v must be set"; exit 1; fi
done

CONF=/var/opt/gitlab/railway-etc-gitlab
mkdir -p "$CONF"
if [ ! -L /etc/gitlab ]; then
  if [ -z "$(ls -A "$CONF")" ]; then cp -a /etc/gitlab/. "$CONF"/ 2>/dev/null || true; fi
  rm -rf /etc/gitlab
  ln -s "$CONF" /etc/gitlab
fi

# Railway terminates HTTPS in front, and Git over SSH arrives through the TCP proxy on its own host and port.
SSH_HOST="${RAILWAY_TCP_PROXY_DOMAIN:-$RAILWAY_PUBLIC_DOMAIN}"
SSH_PORT="${RAILWAY_TCP_PROXY_PORT:-22}"
export GITLAB_OMNIBUS_CONFIG="
external_url 'https://${RAILWAY_PUBLIC_DOMAIN}'
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['proxy_set_headers'] = { 'X-Forwarded-Proto' => 'https', 'X-Forwarded-Ssl' => 'on' }
gitlab_rails['gitlab_ssh_host'] = '${SSH_HOST}'
gitlab_rails['gitlab_shell_ssh_port'] = ${SSH_PORT}
puma['worker_processes'] = 0
sidekiq['concurrency'] = 10
prometheus_monitoring['enable'] = false
registry['enable'] = false
gitlab_pages['enable'] = false
gitlab_kas['enable'] = false
${GITLAB_EXTRA_CONFIG:-}
"

# New GitLab instances allow sign-up (with admin approval). Turn it off once, as soon as GitLab is up.
if [ ! -f "$CONF/.railway-signup-off" ]; then
  (
    until curl -fs -o /dev/null http://127.0.0.1/-/readiness; do sleep 10; done
    if gitlab-rails runner "ApplicationSetting.current.update!(signup_enabled: false)" >/dev/null 2>&1; then
      touch "$CONF/.railway-signup-off"
      echo "[railway] sign-up turned off"
    else
      echo "[railway] could not turn sign-up off; do it under Admin > Settings > General"
    fi
  ) &
fi

exec /assets/init-container
