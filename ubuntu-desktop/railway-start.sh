#!/bin/sh
# The desktop, its terminal and everything signed in on it are one login away, so it doesn't start without one.
if [ -z "$CUSTOM_USER" ] || [ ${#PASSWORD} -lt 12 ]; then
  echo "[railway] CUSTOM_USER and PASSWORD (12+ characters) must be set; not starting a desktop without a login"
  exit 1
fi
exec /init
