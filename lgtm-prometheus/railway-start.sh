#!/bin/sh
# Retention comes from variables so it can be raised with the volume: by default 4 GB or 30 days, whichever is hit first.
exec /bin/prometheus \
  --config.file=/etc/prometheus/railway.yml \
  --storage.tsdb.path=/prometheus \
  --storage.tsdb.retention.size="${PROMETHEUS_RETENTION_SIZE:-4GB}" \
  --storage.tsdb.retention.time="${PROMETHEUS_RETENTION_TIME:-30d}" \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-remote-write-receiver \
  --web.enable-otlp-receiver \
  --enable-feature=exemplar-storage
