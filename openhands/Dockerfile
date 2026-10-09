# OpenHands Agent Canvas on Railway: the official all-in-one image (Canvas UI, agent server, automations,
# bundled VS Code) plus the Claude Code and Codex CLIs, so their subscription logins work from the editor's
# terminal and the Claude Code / Codex agents in Canvas pick them up.
ARG AGENT_CANVAS_VERSION=1.26.0
FROM ghcr.io/openhands/agent-canvas:${AGENT_CANVAS_VERSION}
USER root
RUN npm install -g @anthropic-ai/claude-code @openai/codex && npm cache clean --force
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
