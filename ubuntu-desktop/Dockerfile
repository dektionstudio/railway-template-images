# Ubuntu Desktop on Railway: linuxserver's webtop (Ubuntu 24.04, XFCE, streamed to the browser by Selkies) set up
# as a dev desktop: Node.js 22, the Claude Code and Codex CLIs, Google Chrome and VS Code. The desktop user's home
# (/config) is the volume.
ARG WEBTOP_TAG=ubuntu-xfce-36e96c40-ls6
FROM lscr.io/linuxserver/webtop:${WEBTOP_TAG}

# Upstream sizes the virtual screen at 15360x8640, which holds hundreds of MB for the framebuffer alone.
# 4K is plenty: the desktop still resizes to the browser window.
ENV MAX_RES=3840x2160

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg git build-essential \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && curl -fsSL -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
 && curl -fsSL -o /tmp/code.deb "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" \
 && apt-get install -y /tmp/chrome.deb /tmp/code.deb \
 && rm -f /tmp/chrome.deb /tmp/code.deb \
 && npm install -g @anthropic-ai/claude-code @openai/codex \
 && npm cache clean --force \
 && rm -rf /var/lib/apt/lists/*

# Chrome and VS Code need these flags in a container without user namespaces and with a small /dev/shm.
# Wrappers in /usr/local/bin come first in PATH, so menus, xdg-open and terminals all get them.
RUN printf '#!/bin/sh\nexec /usr/bin/google-chrome-stable --no-sandbox --disable-dev-shm-usage --no-first-run "$@"\n' > /usr/local/bin/google-chrome \
 && cp /usr/local/bin/google-chrome /usr/local/bin/google-chrome-stable \
 && printf '#!/bin/sh\nexec /usr/bin/code --no-sandbox --disable-dev-shm-usage "$@"\n' > /usr/local/bin/code \
 && chmod +x /usr/local/bin/google-chrome /usr/local/bin/google-chrome-stable /usr/local/bin/code \
 && for f in $(grep -rl -e /usr/bin/google-chrome-stable -e /usr/share/code/code /usr/share/applications 2>/dev/null); do \
      sed -i -e 's|/usr/bin/google-chrome-stable|/usr/local/bin/google-chrome-stable|g' -e 's|/usr/share/code/code|/usr/local/bin/code|g' "$f"; \
    done \
 && update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/google-chrome 300

# An unauthenticated /railway-health for Railway's healthcheck. It proxies to the Selkies stream server (the
# placeholder CWS becomes its port at start), so it fails when the desktop's backend is down; Selkies may answer
# a plain GET with 426, which counts as up.
RUN sed -i '0,/listen \[::\]:3000 default_server;/s//listen [::]:3000 default_server;\n  location = \/railway-health {\n    auth_basic off;\n    proxy_pass http:\/\/127.0.0.1:CWS\/;\n    proxy_intercept_errors on;\n    error_page 426 = @railway_up;\n  }\n  location @railway_up { auth_basic off; return 200 "ok"; }/' /defaults/default.conf \
 && grep -q 'location = /railway-health' /defaults/default.conf

COPY root/ /
RUN chmod +x /custom-cont-init.d/30-railway
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
