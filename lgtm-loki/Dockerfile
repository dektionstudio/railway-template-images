# Loki for the Railway Grafana stack: single binary, logs on the volume, OTLP ingest, and a retention period so the
# volume doesn't fill up.
ARG LOKI_VERSION=3.7.10
FROM grafana/loki:${LOKI_VERSION}
COPY loki.yaml /etc/loki/railway.yaml
CMD ["-config.file=/etc/loki/railway.yaml", "-config.expand-env=true"]
