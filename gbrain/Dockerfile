# GBrain on Railway: the brain on Postgres + pgvector, served over HTTP MCP (OAuth 2.1, admin dashboard) with the
# jobs worker next to it. Upstream ships no image; this installs the tagged release the way its docs describe
# (git clone + bun install, autopilot install off).
FROM oven/bun:1.4.3-debian
ARG GBRAIN_REF=v0.60.311.0
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "${GBRAIN_REF}" https://github.com/garrytan/gbrain.git /opt/gbrain \
 && cd /opt/gbrain \
 && GBRAIN_NO_AUTOPILOT_INSTALL=1 bun install --frozen-lockfile --production \
 && chmod +x src/cli.ts \
 && ln -s /opt/gbrain/src/cli.ts /usr/local/bin/gbrain \
 && rm -rf .git test tests evals
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/bash", "/railway-start.sh"]
