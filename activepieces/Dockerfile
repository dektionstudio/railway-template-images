# Activepieces (https://github.com/activepieces/activepieces, MIT community edition) for Railway: the official
# image plus one start step. The first account that signs up owns the platform, and later sign-ups need an
# invitation. On a public URL that first sign-up is a race, so railway-claim.mjs signs the owner up from
# ADMIN_EMAIL / ADMIN_PASSWORD as soon as the API answers.
ARG AP_VERSION=0.92.0
FROM ghcr.io/activepieces/activepieces:${AP_VERSION}
COPY railway-start.sh railway-claim.mjs /usr/local/bin/
RUN chmod 755 /usr/local/bin/railway-start.sh
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
