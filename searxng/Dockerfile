# SearXNG (https://github.com/searxng/searxng, AGPL-3.0) for Railway, as a private search backend for AI tools.
# The official image plus a settings file that turns on the JSON API (which MCP servers and agents need) and
# turns off the public-instance features. The service has no public domain; only services in the same Railway
# project reach it. SEARXNG_SECRET comes from Railway.
ARG SEARXNG_VERSION=2026.9.25-12f8b6515
FROM searxng/searxng:${SEARXNG_VERSION}
COPY settings.yml /etc/searxng/settings.yml
