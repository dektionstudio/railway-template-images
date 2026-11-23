# Ollama (https://github.com/ollama/ollama, MIT) for Railway. Ollama has no authentication: anyone who finds
# its address can use (and pull or delete) your models. Here the public domain reaches Caddy, which lets through
# requests that carry OLLAMA_API_KEY as a bearer token. Ollama itself listens on port 11434 for the project's
# private network only (Railway routes the public domain to PORT and nothing else), so Open WebUI next to it
# connects without the key.
ARG OLLAMA_VERSION=0.40.17
FROM caddy:2.11.4 AS caddy
FROM ollama/ollama:${OLLAMA_VERSION}
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/bash", "/railway-start.sh"]
