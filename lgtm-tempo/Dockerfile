# Tempo for the Railway Grafana stack: single binary (Tempo 3 needs no Kafka in this mode), traces on the volume,
# span metrics and service graphs written to Prometheus.
ARG TEMPO_VERSION=3.1.1
FROM grafana/tempo:${TEMPO_VERSION}
COPY tempo.yaml /etc/tempo.yaml
CMD ["-target=all", "-config.file=/etc/tempo.yaml", "-config.expand-env=true"]
