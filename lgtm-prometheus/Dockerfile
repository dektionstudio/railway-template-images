# Prometheus for the Railway Grafana stack: receives metrics over OTLP (from the collector) and remote write (span
# metrics from Tempo), keeps them on the volume with size and time limits.
ARG PROMETHEUS_VERSION=v3.16.0
FROM prom/prometheus:${PROMETHEUS_VERSION}
COPY prometheus.yml /etc/prometheus/railway.yml
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
