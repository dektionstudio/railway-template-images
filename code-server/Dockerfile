# code-server (VS Code in the browser) for Railway: the official image, pinned, plus Node.js 22 and the
# Claude Code and Codex CLIs for its terminal. The start step runs as root only to hand the Railway volume
# (mounted as root) to the coder user, then runs code-server as coder.
ARG CODE_SERVER_VERSION=4.141.0
FROM codercom/code-server:${CODE_SERVER_VERSION}
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g @anthropic-ai/claude-code @openai/codex \
 && npm cache clean --force
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
