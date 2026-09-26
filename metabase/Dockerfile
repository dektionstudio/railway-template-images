# Metabase (https://github.com/metabase/metabase, AGPL-3.0) for Railway: the official image plus one start step.
# A new Metabase hands its first-run setup (and the admin account) to whoever opens it first. railway-claim.sh
# completes that setup from MB_ADMIN_EMAIL / MB_ADMIN_PASSWORD with Metabase's own setup token.
ARG METABASE_VERSION=v0.63.18
FROM metabase/metabase:${METABASE_VERSION}
COPY railway-start.sh railway-claim.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/railway-start.sh /usr/local/bin/railway-claim.sh
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
