# EmDash on Railway: EmDash's Node blog starter (emdash-cms/templates, pinned) with the database and uploads on
# the volume, and Caddy in front so the admin and its first-run setup need a password before anyone can claim
# the site (EmDash's setup wizard makes whoever arrives first the admin).
ARG TEMPLATES_COMMIT=a7bb43df40b2a1dbc63495579be612837e95aa2e
FROM caddy:2.10.2 AS caddy

FROM node:24-bookworm-slim AS build
ARG TEMPLATES_COMMIT
# The public URL is needed at build time for image optimization of uploaded media.
ARG EMDASH_SITE_URL
ENV EMDASH_SITE_URL=${EMDASH_SITE_URL}
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/* \
 && npm install -g pnpm@11.9.0
# Built in /app, where it runs: Astro bakes absolute paths (its session store) into the build.
RUN git clone https://github.com/emdash-cms/templates /tmp/templates && cd /tmp/templates && git checkout "$TEMPLATES_COMMIT"  && mkdir -p /app && cp -r /tmp/templates/blog/. /app/ && rm -rf /tmp/templates
WORKDIR /app
COPY astro.config.mjs ./astro.config.mjs
RUN pnpm install && pnpm build

FROM node:24-bookworm-slim
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY --from=build --chown=node:node /app /app
COPY Caddyfile /etc/caddy/Caddyfile
COPY railway-start.sh /railway-start.sh
WORKDIR /app
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
