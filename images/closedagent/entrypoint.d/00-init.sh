#!/usr/bin/env bash
set -euo pipefail

# Ensure image PATH is preserved for login shells
echo "export PATH=\"$PATH\"" | tee -a /etc/profile > /dev/null

echo "Fixing permissions"

USER_ID=$(id -u agent)
GROUP_ID=$(id -g agent)

chown -R "$USER_ID:$GROUP_ID" "$HOME/.cache"
chown -R "$USER_ID:$GROUP_ID" "$HOME/.config"
chown -R "$USER_ID:$GROUP_ID" "$HOME/.local"

echo
