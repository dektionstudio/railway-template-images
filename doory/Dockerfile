# Doory on Railway in one container: the web app (built frontend, served by nginx) and the Django backend under
# uvicorn, which serves the API and the real-time co-editing WebSockets from one process. Upstream runs them as
# separate containers sharing a media volume; Railway gives a volume to one service, so they share a container.
ARG DOORY_COMMIT=d4baf4e03cc0485c73a13c2f2ffee645b03fc54f

FROM debian:bookworm-slim AS src
ARG DOORY_COMMIT
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/* \
 && git clone https://github.com/shaongitbd/doory /src && cd /src && git checkout "$DOORY_COMMIT"

FROM node:22-alpine AS web
WORKDIR /app
COPY --from=src /src/frontend/package.json /src/frontend/package-lock.json ./
RUN npm ci --ignore-scripts
COPY --from=src /src/frontend/ ./
RUN npm run build

FROM python:3.14-slim AS deps
ENV PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY --from=src /src/backend/requirements.txt .
RUN pip install -r requirements.txt

FROM python:3.14-slim
RUN apt-get update && apt-get install -y --no-install-recommends nginx && rm -rf /var/lib/apt/lists/* \
 && rm -f /etc/nginx/sites-enabled/default
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 PATH="/opt/venv/bin:$PATH" \
    DJANGO_SETTINGS_MODULE=doory.settings.prod MEDIA_ROOT=/app/media EXPORT_STORAGE_ROOT=/app/exports \
    SERVER_PDF_ENABLED=false
RUN groupadd --system --gid 10001 doory \
 && useradd --system --uid 10001 --gid doory --home-dir /app --shell /usr/sbin/nologin doory
COPY --from=deps /opt/venv /opt/venv
WORKDIR /app
COPY --from=src --chown=doory:doory /src/backend/ /app/
COPY --from=src /src/LICENSE /src/NOTICE /app/
COPY --from=web /app/dist /usr/share/nginx/html
COPY --from=src /src/frontend/nginx/security-headers.conf /etc/nginx/snippets/security-headers.conf
# Upstream's nginx config, pointed at the backend in this container and at the media folder on the volume.
COPY --from=src /src/frontend/nginx.conf /etc/nginx/conf.d/doory.conf
RUN sed -i \
      -e '/^resolver /d' \
      -e 's|server doory-api:8000 resolve;|server 127.0.0.1:8000;|' \
      -e 's|server doory-realtime:8001 resolve;|server 127.0.0.1:8000;|' \
      -e 's|server doory-mcp:8002 resolve;|server 127.0.0.1:8000;|' \
      -e 's|/srv/media/|/app/media/|g' \
      -e 's|set_real_ip_from 127.0.0.1;|set_real_ip_from 127.0.0.1;\nset_real_ip_from 100.64.0.0/10;|' \
      /etc/nginx/conf.d/doory.conf \
 && grep -q 'server 127.0.0.1:8000;' /etc/nginx/conf.d/doory.conf && ! grep -v '^ *#' /etc/nginx/conf.d/doory.conf | grep -q 'doory-api|/srv/media'\|/srv/media' /etc/nginx/conf.d/doory.conf \
 && chmod +x /app/docker-entrypoint.sh \
 && mkdir -p /app/media /app/exports /app/staticfiles && chown doory:doory /app /app/media /app/exports /app/staticfiles
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
