# OpenMuse web app for Railway: the Expo web export, served by Caddy with an SPA fallback.
# EXPO_PUBLIC_API_URL is baked into the bundle at build time (Railway passes service variables as build args).
FROM node:24-bookworm-slim AS build
ARG OPENMUSE_COMMIT=d0b3a6b3ea461bc938a5dea6c46e65eefdb1b933
ARG EXPO_PUBLIC_API_URL
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git init -q && git remote add origin https://github.com/CopilotKit/openmuse.git  && git fetch -q --depth 1 origin "$OPENMUSE_COMMIT" && git checkout -q FETCH_HEAD && rm -rf .git
RUN test -n "$EXPO_PUBLIC_API_URL" || (echo "EXPO_PUBLIC_API_URL is not set" && exit 1)
RUN corepack enable && pnpm install --frozen-lockfile  && EXPO_PUBLIC_API_URL="$EXPO_PUBLIC_API_URL" pnpm --dir apps/mobile exec expo export --platform web --output-dir dist/web --clear

FROM caddy:2.11.4
COPY --from=build /app/apps/mobile/dist/web /srv
COPY Caddyfile /etc/caddy/Caddyfile
