# Odoo 20 on Railway: the official image with a start step that writes the config (one database, the database
# manager off, a generated master password, proxy mode), sets up the database and the admin login on first
# start, and runs Odoo as the odoo user with its files on the volume.
ARG ODOO_TAG=20.0-20261015
FROM odoo:${ODOO_TAG}
USER root
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/bash", "/railway-start.sh"]
