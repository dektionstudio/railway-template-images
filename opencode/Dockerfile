# OpenCode (https://github.com/anomalyco/opencode, MIT) web UI behind its own basic auth.
# The home directory (projects, provider logins, sessions) goes on a Railway volume.
# Railway passes service variables to build args, so changing OPENCODE_VERSION and redeploying upgrades it.
FROM node:24-bookworm-slim

ARG OPENCODE_VERSION=1.18.32
RUN apt-get update && apt-get install -y --no-install-recommends \
      git ca-certificates curl ripgrep openssh-client python3 procps less nano \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g --no-fund --no-audit "opencode-ai@${OPENCODE_VERSION}" \
    && npm cache clean --force \
    && useradd -m -u 1001 -s /bin/bash dev

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
