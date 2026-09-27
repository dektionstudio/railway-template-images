# Password gate for a private SearXNG on Railway. SearXNG has no login of its own, and an open instance on a
# public URL becomes a free search proxy for bots. Caddy asks for SEARXNG_USERNAME / SEARXNG_PASSWORD and
# forwards to SearXNG on the private network; only /healthz is open, for Railway's healthcheck.
FROM caddy:2.11.4
COPY Caddyfile /etc/caddy/Caddyfile
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
