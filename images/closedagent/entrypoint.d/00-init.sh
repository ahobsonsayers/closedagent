#!/usr/bin/env bash
set -euo pipefail

# Ensure image PATH is preserved for login shells
echo "export PATH=\"$PATH\"" | sudo tee -a /etc/profile > /dev/null

echo "Fixing permissions"

fix_perms() {
  local path
  path="$1"

  find "$path" -mindepth 1 \
    \( ! -user agent -o ! -group agent \) \
    -exec chown "$user:$group" -- {} +
}

fix_perms "$HOME"/.cache
fix_perms "$HOME"/.config
fix_perms "$HOME"/.local

echo
