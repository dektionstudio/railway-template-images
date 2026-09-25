# Added to ~/.bashrc by the coding box on first boot.
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
export EDITOR=nano

if [ -z "${CODING_BOX_GREETED:-}" ] && [ -t 1 ]; then
  export CODING_BOX_GREETED=1
  echo "Coding box: claude, codex and gemini are installed. This tmux session keeps running when you close the tab."
  echo "Work in ~/ (it is on the volume). Update the CLIs with: install-agents --update"
fi
