# OpenMuse API (and its in-process task worker) for Railway, built from a pinned commit: upstream has no releases yet.
FROM node:24-bookworm-slim AS build
ARG OPENMUSE_COMMIT=d0b3a6b3ea461bc938a5dea6c46e65eefdb1b933
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git init -q && git remote add origin https://github.com/CopilotKit/openmuse.git  && git fetch -q --depth 1 origin "$OPENMUSE_COMMIT" && git checkout -q FETCH_HEAD && rm -rf .git
RUN corepack enable && pnpm install --frozen-lockfile && pnpm build:server

FROM node:24-bookworm-slim
WORKDIR /app
COPY --from=build /app /app
ENV NODE_ENV=production
EXPOSE 8787
CMD ["node", "dist/apps/server/src/index.js"]
