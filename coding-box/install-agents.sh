#!/bin/bash
# Installs (or updates) the coding agent CLIs into ~/.npm-global, which lives on the volume.
#   install-agents            install whatever is missing
#   install-agents --update   update all of them
set -u
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"

packages="@anthropic-ai/claude-code @openai/codex @google/gemini-cli"
missing=""
for p in $packages; do
  if [ "${1:-}" = "--update" ] || [ ! -d "$HOME/.npm-global/lib/node_modules/$p" ]; then
    missing="$missing $p"
  fi
done

if [ -n "$missing" ]; then
  echo "Installing:$missing"
  npm install -g --no-fund --no-audit $missing
fi
claude --version 2>/dev/null | head -1
codex --version 2>/dev/null | head -1
gemini --version 2>/dev/null | head -1
