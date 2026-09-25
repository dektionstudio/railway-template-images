#!/bin/bash
# Prepares the home volume, starts sshd, installs the agent CLIs on first boot, then serves a
# password-protected browser terminal attached to a persistent tmux session.
set -eu

: "${BOX_PASSWORD:?BOX_PASSWORD is required}"
PORT="${PORT:-7681}"
HOME_DIR=/home/dev

# Railway mounts the volume owned by root and empty on first boot.
if [ ! -f "$HOME_DIR/.bashrc" ]; then
  cp -a /opt/skel/. "$HOME_DIR/"
fi
if ! grep -q bashrc-extra "$HOME_DIR/.bashrc"; then
  echo '[ -f /opt/bashrc-extra.sh ] && . /opt/bashrc-extra.sh' >> "$HOME_DIR/.bashrc"
fi
chown dev:dev "$HOME_DIR" "$HOME_DIR/.bashrc"
echo "dev:${BOX_PASSWORD}" | chpasswd

# Host keys live on the volume so SSH clients don't see a new fingerprint after every deploy.
KEYS="$HOME_DIR/.sshd-host-keys"
mkdir -p "$KEYS" && chown root:root "$KEYS" && chmod 700 "$KEYS"
[ -f "$KEYS/ssh_host_ed25519_key" ] || ssh-keygen -q -t ed25519 -N "" -f "$KEYS/ssh_host_ed25519_key"
if [ -n "${SSH_AUTHORIZED_KEYS:-}" ]; then
  install -d -m 700 -o dev -g dev "$HOME_DIR/.ssh"
  printf '%s\n' "$SSH_AUTHORIZED_KEYS" > "$HOME_DIR/.ssh/authorized_keys"
  chown dev:dev "$HOME_DIR/.ssh/authorized_keys" && chmod 600 "$HOME_DIR/.ssh/authorized_keys"
fi
cat > /etc/ssh/sshd_config.d/box.conf <<EOF
HostKey $KEYS/ssh_host_ed25519_key
PermitRootLogin no
PasswordAuthentication ${SSH_PASSWORD_AUTH:-yes}
AllowUsers dev
EOF
/usr/sbin/sshd

# SSH sessions don't inherit the container environment, so hand them the optional API keys.
: > /etc/profile.d/box-keys.sh
for v in ANTHROPIC_API_KEY OPENAI_API_KEY GEMINI_API_KEY GITHUB_TOKEN; do
  if [ -n "${!v:-}" ]; then printf 'export %s=%q\n' "$v" "${!v}" >> /etc/profile.d/box-keys.sh; fi
done
chown root:dev /etc/profile.d/box-keys.sh && chmod 640 /etc/profile.d/box-keys.sh

if [ "${INSTALL_AGENTS:-true}" = "true" ]; then
  runuser -l dev -c install-agents || echo "Agent install failed; run install-agents in the terminal to retry."
fi

echo "Browser terminal on port $PORT (user dev). SSH on port 22 through the TCP proxy."
cd "$HOME_DIR"
exec runuser -u dev -- env HOME="$HOME_DIR" USER=dev LOGNAME=dev SHELL=/bin/bash \
  ttyd --port "$PORT" --writable --credential "dev:${BOX_PASSWORD}" -t titleFixed="Coding box" \
  tmux new-session -A -s main
