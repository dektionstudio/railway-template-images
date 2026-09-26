#!/bin/sh
# Railway mounts the volume owned by root, and the daemon runs as the image's open-design user.
# OD_DATA_DIR (the daemon's data) and HOME (agent CLI logins and settings) both live on the volume.
set -e
mkdir -p "${OD_DATA_DIR:-/data/od}" "${HOME:-/data/home}"
chown -R open-design:open-design "$(dirname "${OD_DATA_DIR:-/data/od}")"
exec su-exec open-design "$@"
