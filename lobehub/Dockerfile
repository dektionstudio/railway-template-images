# LobeHub (https://github.com/lobehub/lobehub) for Railway: the official image plus one start step.
# LobeHub's internal service calls need an RS256 signing key in JWKS_KEY, which a Railway template can't
# generate. railway-start.mjs creates it on first start, keeps it in the project's private bucket, and then
# runs the image's own startServer.js.
ARG LOBEHUB_VERSION=latest
FROM lobehub/lobehub:${LOBEHUB_VERSION}
COPY railway-start.mjs /app/railway-start.mjs
# The image's ENTRYPOINT is /bin/node.
CMD ["/app/railway-start.mjs"]
