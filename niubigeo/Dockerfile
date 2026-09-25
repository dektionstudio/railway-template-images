# NiubiGEO (https://github.com/Albert-Weasker/niubigeo, Apache-2.0) for Railway.
# Upstream says not to expose the workbench without authentication, and its scheduling worker needs the
# same data directory as the workbench. Railway volumes attach to one service, so this image runs both
# in one container behind a small password-protected proxy (railway-start.mjs).
FROM ghcr.io/albert-weasker/niubigeo:v0.2.0
COPY railway-start.mjs /railway-start.mjs
CMD ["node", "/railway-start.mjs"]
