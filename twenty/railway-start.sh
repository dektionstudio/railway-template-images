#!/bin/sh
# Start Twenty the way the image does (its entrypoint has already run the migrations) and create the admin
# account and workspace in the background. Shell and curl keep this step's memory near zero: Twenty needs most
# of a 1 GB service for itself.
if [ -n "$TWENTY_ADMIN_EMAIL" ] && [ -n "$TWENTY_ADMIN_PASSWORD" ]; then
  sh /app/railway/railway-claim.sh &
fi
exec node dist/main
