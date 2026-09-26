# LibreChat (https://github.com/LibreChat-AI/LibreChat, MIT) for Railway: a pinned release image instead of
# the nightly dev image, plus one start step. LibreChat makes the first account that registers the admin; on
# a public URL that's a race, so this template keeps registration closed and creates the admin account from
# ADMIN_EMAIL / ADMIN_PASSWORD with LibreChat's own create-user script.
ARG LIBRECHAT_VERSION=v0.8.7
FROM ghcr.io/danny-avila/librechat:${LIBRECHAT_VERSION}
USER root
RUN apk add --no-cache su-exec
COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh
CMD ["railway-start.sh"]
