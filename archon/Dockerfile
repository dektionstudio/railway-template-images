# Archon on Railway: the official image (Claude Code, Codex and Pi agents, workflows, build and merge queues) on
# Postgres with its own web login turned on, and the owner account created before the public port opens.
ARG ARCHON_TAG=0.12.1
FROM ghcr.io/coleam00/archon:${ARCHON_TAG}
USER root
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/bash", "/railway-start.sh"]
