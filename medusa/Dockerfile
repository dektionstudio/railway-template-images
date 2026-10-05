# Medusa v2 backend and admin for Railway, built from Medusa's official dtc-starter at a pinned commit (it has
# no release tags), with this folder's config, setup script and start step.
FROM node:24-bookworm-slim
ARG DTC_COMMIT=15ef93da7d155ad990d8cc6db0296446fecbdfe6
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git init -q && git remote add origin https://github.com/medusajs/dtc-starter.git \
 && git fetch -q --depth 1 origin "$DTC_COMMIT" && git checkout -q FETCH_HEAD && rm -rf .git
COPY medusa-config.ts apps/backend/medusa-config.ts
COPY railway-setup.ts apps/backend/src/scripts/railway-setup.ts
RUN corepack enable && pnpm install --frozen-lockfile --filter "@dtc/backend..."
# medusa build needs about 1.5 GB of heap (it runs out of memory at 1 GB); it doesn't touch the database.
RUN cd apps/backend && NODE_OPTIONS=--max-old-space-size=2048 pnpm exec medusa build
ENV NODE_ENV=production
COPY railway-start.sh /railway-start.sh
EXPOSE 9000
CMD ["sh", "/railway-start.sh"]
