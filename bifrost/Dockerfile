# Bifrost AI gateway for Railway: writes a locked-down config.json on every start, then runs the image as usual.
ARG BIFROST_VERSION=v2.2.4
FROM maximhq/bifrost:${BIFROST_VERSION}
# Railway volumes are owned by root; the image's entrypoint then fixes ownership of the data directory.
USER root
COPY railway-start.sh /railway-start.sh
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
