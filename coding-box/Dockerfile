# Ubuntu box for AI coding agents: browser terminal (ttyd) + SSH, home directory on a Railway volume.
# The agent CLIs are baked into the image under /opt/agents (owned by dev, so they can update themselves);
# the volume only holds the home directory: projects, logins and settings. Railway's trial volume is 0.5 GB.
FROM ubuntu:24.04

ARG TTYD_VERSION=1.7.7
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl wget gnupg git openssh-server sudo tmux vim nano less htop ripgrep fd-find jq \
      unzip zip python3 python3-pip python3-venv build-essential procps iproute2 dnsutils \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && curl -fsSL -o /usr/share/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends nodejs gh \
    && curl -fsSL -o /usr/local/bin/ttyd "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
    && chmod +x /usr/local/bin/ttyd \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu 24.04 ships a default "ubuntu" user with uid 1000; replace it with "dev".
RUN userdel -r ubuntu 2>/dev/null || true \
    && useradd -m -u 1000 -s /bin/bash dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && mkdir -p /run/sshd /opt/skel \
    && cp -a /home/dev/. /opt/skel/

ENV NPM_CONFIG_PREFIX=/opt/agents PATH=/opt/agents/bin:$PATH
RUN mkdir -p /opt/agents && chown dev:dev /opt/agents \
    && su dev -c "npm install -g --no-fund --no-audit @anthropic-ai/claude-code @openai/codex @google/gemini-cli" \
    && su dev -c "npm cache clean --force" \
    && rm -rf /home/dev/.npm \
    && sed -i 's#^PATH="#PATH="/opt/agents/bin:#' /etc/environment \
    && echo 'NPM_CONFIG_PREFIX="/opt/agents"' >> /etc/environment
# /etc/environment is what sshd sessions get, including non-interactive ones (ssh box claude, VS Code Remote-SSH).

COPY bashrc-extra.sh /opt/bashrc-extra.sh
COPY install-agents.sh /usr/local/bin/install-agents
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/install-agents /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
