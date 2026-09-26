# Railway template images

Dockerfiles behind the Railway templates published by Dektion Studio. Railway builds a folder from this repo when someone deploys a template that needs one; the other templates use upstream images directly.

## Deploy

Every template was deployed and tested end to end before it was published; each template's page on Railway says what was tested.

- [Activepieces](https://railway.com/deploy/activepieces-4?referralCode=8ySoaR): automation with Postgres and Redis, owner account set at deploy
- [Claude Code Box](https://railway.com/deploy/claude-code-box?referralCode=8ySoaR): Ubuntu with Claude Code, Codex and Gemini CLI, browser terminal and SSH
- [Ghost](https://railway.com/deploy/ghost-1?referralCode=8ySoaR): Ghost 6 with MySQL, owner account set at deploy
- [Hermes Agent](https://railway.com/deploy/hermes-agent-official-image?referralCode=8ySoaR): Nous Research's agent on the official image, with an API key and Telegram
- [Hermes Agent with Hindsight Memory](https://railway.com/deploy/hermes-agent-with-hindsight-memory?referralCode=8ySoaR): Hermes with self-hosted Hindsight memory
- [Hindsight Memory Server](https://railway.com/deploy/hindsight-agent-memory-secure-slim?referralCode=8ySoaR): long-term memory for AI agents over MCP and REST
- [LibreChat](https://railway.com/deploy/librechat-2?referralCode=8ySoaR): pinned release, admin account set at deploy, file search
- [LobeHub](https://railway.com/deploy/lobehub-1?referralCode=8ySoaR): LobeHub with Postgres and private file storage
- [Minecraft](https://railway.com/deploy/minecraft-server-p-1?referralCode=8ySoaR): Paper server with the world on a volume
- [n8n](https://railway.com/deploy/n8n-9?referralCode=8ySoaR): n8n on Postgres, owner account set at deploy
- [NiubiGEO](https://railway.com/deploy/niubigeo?referralCode=8ySoaR): AI brand visibility reports behind a login
- [Open WebUI](https://railway.com/deploy/open-webui-8?referralCode=8ySoaR): Open WebUI on Postgres with pgvector, admin account set at deploy
- [OpenCode](https://railway.com/deploy/opencode-web?referralCode=8ySoaR): OpenCode's web UI with a password
- [OpenDesign](https://railway.com/deploy/opendesign?referralCode=8ySoaR): OpenDesign with Claude Code, Codex and OpenCode installed
- [Paperclip](https://railway.com/deploy/paperclip-official-image?referralCode=8ySoaR): Paperclip with Postgres, first admin invite in the deploy logs
- [SillyTavern](https://railway.com/deploy/sillytavern-official-image?referralCode=8ySoaR): official image, password-protected, chats on a volume
- [WordPress](https://railway.com/deploy/wordpress-mariadb-wp-cli?referralCode=8ySoaR): WordPress on MariaDB with WP-CLI

These links carry my Railway referral code: if you create a Railway account through one, Railway credits me for the referral.

## What each folder adds

- `activepieces`: the official Activepieces image plus a start step that signs the platform owner up from ADMIN_EMAIL / ADMIN_PASSWORD (later sign-ups need an invitation)
- `coding-box`: Ubuntu 24.04 with a browser terminal (ttyd), SSH and tmux, with Claude Code, Codex and Gemini CLI preinstalled. The home directory goes on a Railway volume
- `ghost`: the official Ghost image plus a start step that creates the owner account through Ghost's setup API from GHOST_ADMIN_EMAIL / GHOST_ADMIN_PASSWORD
- `librechat`: a pinned LibreChat release plus a start step that creates the admin account from ADMIN_EMAIL / ADMIN_PASSWORD (registration stays closed), keeps uploads on a volume and adds an OpenRouter endpoint
- `lobehub`: LobeHub's official image plus a start step that creates the file bucket with a CORS rule for browser uploads, and a JWKS_KEY kept in that private bucket
- `metabase`: the official Metabase image plus a start step that completes the first-run setup; not published yet, since it needs more than 1 GB of RAM to start
- `n8n`: the official n8n image plus a start step that sets up the owner account from N8N_OWNER_EMAIL / N8N_OWNER_PASSWORD once n8n is ready
- `niubigeo`: NiubiGEO's official image with its workbench and scheduling worker in one container, behind a password
- `open-design`: OpenDesign's official image plus the Claude Code, Codex and OpenCode CLIs (upstream leaves them out and suggests a separate layer for servers), data and CLI logins on a volume
- `opencode`: OpenCode's web UI (pinned version, basic auth through OPENCODE_SERVER_PASSWORD), home directory on a Railway volume
- `paperclip`: Paperclip's official image plus a start step that prints the first admin's one-time invite link in the deploy logs (a public instance can't be claimed from the browser)
- `wordpress`: the official WordPress image with prefork only, 128 MB uploads, real client IPs behind Railway's proxy and WP-CLI

MIT licensed. Issues and pull requests are welcome.
