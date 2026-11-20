# Grafana for the Railway Grafana stack: Prometheus, Loki and Tempo provisioned as data sources (addresses from
# variables), with traces linked to their logs and metrics.
ARG GRAFANA_VERSION=13.3.1
FROM grafana/grafana:${GRAFANA_VERSION}
COPY provisioning/datasources/railway.yaml /etc/grafana/provisioning/datasources/railway.yaml
