#!/bin/bash
set -e

if [ -n "$APT_PACKAGES" ]; then
  echo "Installing apt packages"
  sudo apt-get update
  sudo apt-get install -y $APT_PACKAGES
  sudo rm -rf /var/lib/apt/lists/*
  echo
fi

if [ -n "$BREW_PACKAGES" ]; then
  echo "Installing brew packages"
  brew install $BREW_PACKAGES
  echo
fi

if [ -n "$BUN_PACKAGES" ]; then
  echo "Installing bun packages"
  bun install -g $BUN_PACKAGES
  echo
fi

fix_perms() {
  local path="$1"
  local user="$(id -u)"
  local group="$(id -g)"
  
  if [ -d "$path" ]; then
    sudo find "$path" -mindepth 1 \
      \( ! -user "$user" -o ! -group "$group" \) \
      -exec chown "$user:$group" -- {} +
  fi
}

echo "Fixing permissions"
fix_perms "$HOME"/.config
fix_perms "$HOME"/.local
fix_perms "$HOME"/workspace
echo

echo "Running:"
echo "$@"
echo

exec "$@"
