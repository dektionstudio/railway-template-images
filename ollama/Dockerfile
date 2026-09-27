# Ollama (https://github.com/ollama/ollama, MIT) for Railway. Ollama has no authentication: anyone who finds
# its address can use (and pull or delete) your models. Here it listens only inside the container, and Caddy
# in front of it lets through requests that carry OLLAMA_API_KEY as a bearer token.
ARG OLLAMA_VERSION=0.34.4
FROM caddy:2.11.4 AS caddy
FROM ollama/ollama:${OLLAMA_VERSION}
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/bash", "/railway-start.sh"]
