# Ghost (https://github.com/TryGhost/Ghost, MIT) for Railway: the official image plus one start step. A new
# Ghost site lets whoever opens /ghost first create the owner account; on a public URL that's a race.
# railway-claim.mjs creates the owner from GHOST_ADMIN_EMAIL / GHOST_ADMIN_PASSWORD as soon as Ghost answers.
ARG GHOST_VERSION=6.65.0
FROM ghost:${GHOST_VERSION}
COPY railway-start.sh railway-claim.mjs /usr/local/bin/
RUN chmod 755 /usr/local/bin/railway-start.sh
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["node", "current/index.js"]
