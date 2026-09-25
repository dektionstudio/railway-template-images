#!/bin/bash
# Updates Claude Code, Codex and Gemini CLI in /opt/agents. They come preinstalled in the image;
# a redeploy of the same image goes back to the versions it was built with.
set -eu
export NPM_CONFIG_PREFIX=/opt/agents
npm install -g --no-fund --no-audit @anthropic-ai/claude-code@latest @openai/codex@latest @google/gemini-cli@latest
npm cache clean --force >/dev/null 2>&1 || true
claude --version; codex --version; gemini --version
