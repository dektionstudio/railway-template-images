# Pterodactyl Panel (https://github.com/pterodactyl/panel, MIT) for Railway: the official image plus one start
# step. The panel has no sign-up page, so a fresh install has no way in until someone runs a CLI command.
# railway-start.sh creates the first admin from PTERODACTYL_ADMIN_EMAIL / PTERODACTYL_ADMIN_PASSWORD after the
# image's entrypoint has migrated the database, then starts the panel the way the image does.
ARG PTERODACTYL_VERSION=v1.15.1
FROM ghcr.io/pterodactyl/panel:${PTERODACTYL_VERSION}
COPY railway-client.cnf /etc/my.cnf.d/railway-client.cnf
COPY railway-start.sh /railway-start.sh
CMD ["/bin/ash", "/railway-start.sh"]
