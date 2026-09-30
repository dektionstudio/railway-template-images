# OpenMuse browser worker (headless Chromium via Playwright) for Railway, from the same pinned commit as the API.
# Runs as root so it can write the Railway volume at /data; Playwright passes --no-sandbox itself.
FROM node:24-bookworm-slim AS src
ARG OPENMUSE_COMMIT=d0b3a6b3ea461bc938a5dea6c46e65eefdb1b933
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN git init -q && git remote add origin https://github.com/CopilotKit/openmuse.git  && git fetch -q --depth 1 origin "$OPENMUSE_COMMIT" && git checkout -q FETCH_HEAD

FROM mcr.microsoft.com/playwright:v1.62.1-noble
WORKDIR /app
COPY --from=src /src/apps/worker/package.json /src/apps/worker/package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts && mkdir -p /data
COPY --from=src /src/apps/worker/src ./src
# Railway's private network is IPv6, so listen on :: (which also accepts IPv4).
ENV NODE_ENV=production WORKER_DATA_DIR=/data WORKER_HOST=::
EXPOSE 8790
CMD ["node", "--experimental-strip-types", "src/index.ts"]
