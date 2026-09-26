# OpenDesign (https://github.com/nexu-io/open-design, Apache-2.0) for Railway: the official image plus the
# coding-agent CLIs it can drive. Upstream leaves Claude Code, Codex and OpenCode out of the image on purpose
# and suggests a separate layer for servers that need them; this is that layer. libc6-compat is what upstream's
# Dockerfile.local adds so those CLIs run on Alpine.
ARG OD_VERSION=latest
FROM ghcr.io/nexu-io/od:${OD_VERSION}
USER root
RUN apk add --no-cache libc6-compat su-exec \
    && npm install -g --omit=dev @anthropic-ai/claude-code @openai/codex opencode-ai \
    && npm cache clean --force
COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh
# Starts as root only to hand the Railway volume to the open-design user, then runs upstream's command as it.
ENTRYPOINT ["/sbin/tini", "--", "railway-start.sh"]
CMD ["node", "apps/daemon/dist/cli.js", "--no-open"]
