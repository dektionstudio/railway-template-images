# Twenty (https://github.com/twentyhq/twenty, AGPL-3.0) for Railway: the official image plus one start step.
# On a fresh Twenty the first person who signs up creates the only workspace and becomes the server admin; on a
# public URL anyone can do that. railway-claim.sh does it from TWENTY_ADMIN_EMAIL / TWENTY_ADMIN_PASSWORD as soon
# as Twenty answers. The image's entrypoint still runs the database migrations first.
ARG TWENTY_VERSION=v2.42.6
FROM twentycrm/twenty:${TWENTY_VERSION}
COPY railway-start.sh railway-claim.sh /app/railway/
CMD ["sh", "/app/railway/railway-start.sh"]
