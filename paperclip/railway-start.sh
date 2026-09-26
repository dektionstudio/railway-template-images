#!/bin/sh
# Runs as the node user (the image's entrypoint drops privileges before this).
set -e
cd /app
# Waits for the server in the background, then prints the first admin's invite link if nobody has claimed
# the instance yet.
node --import ./server/node_modules/tsx/dist/loader.mjs server/railway-bootstrap.mjs &
# Upstream's own start command.
exec node --import ./server/node_modules/tsx/dist/loader.mjs server/dist/index.js
