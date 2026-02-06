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

echo "Fixing permissions"
sudo chown -R "$(id -u):$(id -g)" "$HOME"/.config
sudo chown -R "$(id -u):$(id -g)" "$HOME"/.local
sudo chown -R "$(id -u):$(id -g)" "$HOME"/workspace
echo

echo "Running:"
echo "$@"
echo

exec "$@"
