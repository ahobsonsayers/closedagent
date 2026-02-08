#!/bin/bash
set -e

strip_quotes() {
  local string="$1"
  string=${string#\"}
  string=${string%\"}
  string=${string#\'}
  string=${string%\'}
  echo "$string"
}

fix_perms() {
  local path="$1"
  local user="$(id -u)"
  local group="$(id -g)"

  sudo find "$path" -mindepth 1 \
    \( ! -user "$user" -o ! -group "$group" \) \
    -exec chown "$user:$group" -- {} +
}

if [ -n "$APT_PACKAGES" ]; then
  echo "Installing apt packages"
  sudo apt-get update
  sudo apt-get install -y $(strip_quotes "$APT_PACKAGES")
  sudo rm -rf /var/lib/apt/lists/*
  echo
fi

if [ -n "$BREW_PACKAGES" ]; then
  echo "Installing brew packages"
  brew install $(strip_quotes "$BREW_PACKAGES")
  echo
fi

if [ -n "$BUN_PACKAGES" ]; then
  echo "Installing bun packages"
  bun install -g $(strip_quotes "$BUN_PACKAGES")
  echo
fi

echo "Fixing permissions"
fix_perms "$HOME"/.config
fix_perms "$HOME"/.local
fix_perms "$HOME"/workspace
echo

echo "Running:"
echo "$@"
echo

exec "$@"
