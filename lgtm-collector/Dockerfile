# OpenTelemetry Collector for the Railway Grafana stack: the one public ingest endpoint. OTLP over HTTP and gRPC,
# a bearer token required on every request, then traces to Tempo, logs to Loki and metrics to Prometheus over the
# private network.
ARG COLLECTOR_VERSION=0.165.0
FROM otel/opentelemetry-collector-contrib:${COLLECTOR_VERSION}
COPY config.yaml /etc/otelcol-contrib/railway.yaml
CMD ["--config=/etc/otelcol-contrib/railway.yaml"]
