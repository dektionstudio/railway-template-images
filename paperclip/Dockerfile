# Paperclip (https://github.com/paperclipai/paperclip, MIT) for Railway: the official image, unchanged,
# plus one start step. Paperclip's docs say an internet-facing (authenticated + public) instance can't be
# claimed from the browser; the first admin needs a one-time invite from `paperclipai auth bootstrap-ceo`,
# which the production image can't run as shipped. railway-bootstrap.mjs creates that invite the same way
# and prints the link in the deploy logs, which only members of the Railway project can read.
ARG PAPERCLIP_VERSION=latest
FROM ghcr.io/paperclipai/paperclip:${PAPERCLIP_VERSION}
COPY --chown=node:node railway-bootstrap.mjs /app/server/railway-bootstrap.mjs
COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh
# The image's entrypoint (tini + docker-entrypoint.sh) stays: it fixes volume ownership and drops to the node user.
CMD ["railway-start.sh"]
