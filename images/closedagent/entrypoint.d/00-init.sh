#!/usr/bin/env bash
set -euo pipefail

# Ensure image PATH is preserved for login shells
echo "export PATH=\"$PATH\"" | tee -a /etc/profile > /dev/null

echo "Fixing permissions"

USER_ID=$(id -u agent)
GROUP_ID=$(id -g agent)

fix_perms() {
  local path
  path="$1"

  find "$path" -mindepth 1 \
    \( ! -user "$USER_ID" -o ! -group "$GROUP_ID" \) \
    -exec chown "$USER_ID:$GROUP_ID" -- {} +
}

fix_perms "$HOME"/.cache
fix_perms "$HOME"/.config
fix_perms "$HOME"/.local

echo
