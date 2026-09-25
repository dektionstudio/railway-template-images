#!/bin/sh
# On Railway, the mpm_event symlinks that the upstream php:apache image deletes in a later layer are
# present again at runtime, and Apache stops with "More than one MPM loaded". Remove them at start,
# then hand over to the official entrypoint.
rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.*
exec docker-entrypoint.sh "$@"
