# Railway template images

Dockerfiles behind the Railway templates published by Dektion Studio. Railway builds each folder when someone deploys the template.

- `activepieces`: the official Activepieces image plus a start step that signs the platform owner up from ADMIN_EMAIL / ADMIN_PASSWORD (later sign-ups need an invitation)
- `coding-box`: Ubuntu 24.04 with a browser terminal (ttyd), SSH and tmux, with Claude Code, Codex and Gemini CLI preinstalled. The home directory goes on a Railway volume
- `ghost`: the official Ghost image plus a start step that creates the owner account through Ghost's setup API from GHOST_ADMIN_EMAIL / GHOST_ADMIN_PASSWORD
- `librechat`: a pinned LibreChat release plus a start step that creates the admin account from ADMIN_EMAIL / ADMIN_PASSWORD (registration stays closed), keeps uploads on a volume and adds an OpenRouter endpoint
- `lobehub`: LobeHub's official image plus a start step that creates the file bucket with a CORS rule for browser uploads, and a JWKS_KEY kept in that private bucket
- `n8n`: the official n8n image plus a start step that sets up the owner account from N8N_OWNER_EMAIL / N8N_OWNER_PASSWORD once n8n is ready
- `niubigeo`: NiubiGEO's official image with its workbench and scheduling worker in one container, behind a password
- `paperclip`: Paperclip's official image plus a start step that prints the first admin's one-time invite link in the deploy logs (a public instance can't be claimed from the browser)
- `open-design`: OpenDesign's official image plus the Claude Code, Codex and OpenCode CLIs (upstream leaves them out and suggests a separate layer for servers), data and CLI logins on a volume
- `opencode`: OpenCode's web UI (pinned version, basic auth through OPENCODE_SERVER_PASSWORD), home directory on a Railway volume
- `wordpress`: the official WordPress image with prefork only, 128 MB uploads, real client IPs behind Railway's proxy and WP-CLI

MIT licensed. Issues and pull requests are welcome.
