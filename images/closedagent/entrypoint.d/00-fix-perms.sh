#!/usr/bin/env bash
set -euo pipefail

fix_perms() {
  local path
  local user
  local group

  path="$1"
  user="$(id -u)"
  group="$(id -g)"

  sudo find "$path" -mindepth 1 \
    \( ! -user "$user" -o ! -group "$group" \) \
    -exec chown "$user:$group" -- {} +
}

echo "Fixing permissions"
fix_perms "$HOME"/.config
fix_perms "$HOME"/.local
fix_perms "$HOME"/workspace
echo
