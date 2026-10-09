# CloudCLI (aka Claude Code UI) on Railway: the CloudCLI web and mobile UI with the Claude Code, Codex and OpenCode
# CLIs it drives. A full Debian image with git and build tools, since the agents build and run code here.
FROM node:22-bookworm
ARG CLOUDCLI_VERSION=1.37.4
RUN apt-get update \
 && apt-get install -y --no-install-recommends ripgrep \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g "@cloudcli-ai/cloudcli@${CLOUDCLI_VERSION}" @anthropic-ai/claude-code @openai/codex opencode-ai \
 && npm cache clean --force
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
