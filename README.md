# Railway template images

Dockerfiles behind the Railway templates published by Dektion Studio. Railway builds each folder when someone deploys the template.

- `coding-box`: Ubuntu 24.04 with a browser terminal (ttyd), SSH and tmux, with Claude Code, Codex and Gemini CLI preinstalled. The home directory goes on a Railway volume
- `lobehub`: LobeHub's official image plus a start step that creates the file bucket with a CORS rule for browser uploads, and a JWKS_KEY kept in that private bucket
- `niubigeo`: NiubiGEO's official image with its workbench and scheduling worker in one container, behind a password
- `paperclip`: Paperclip's official image plus a start step that prints the first admin's one-time invite link in the deploy logs (a public instance can't be claimed from the browser)
- `opencode`: OpenCode's web UI (pinned version, basic auth through OPENCODE_SERVER_PASSWORD), home directory on a Railway volume
- `wordpress`: the official WordPress image with prefork only, 128 MB uploads, real client IPs behind Railway's proxy and WP-CLI

MIT licensed. Issues and pull requests are welcome.
