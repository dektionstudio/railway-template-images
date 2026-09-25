# Railway template images

Dockerfiles behind the Railway templates published by Dektion Studio. Railway builds each folder when someone deploys the template.

- `telegram-proxy`: [mtg](https://github.com/9seconds/mtg) (MIT) in fake-TLS mode, with an entrypoint that builds the secret and prints the Telegram link
- `coding-box`: Ubuntu 24.04 with a browser terminal (ttyd), SSH and tmux; installs Claude Code, Codex and Gemini CLI into the home volume on first boot

MIT licensed. Issues and pull requests are welcome.
