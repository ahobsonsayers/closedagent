#!/bin/bash
set -e

echo "Installing apt packages"
if [ -n "$APT_PACKAGES" ]; then
	sudo apt-get update
	sudo apt-get install -y $APT_PACKAGES
	sudo rm -rf /var/lib/apt/lists/*
fi

echo "Installing brew packages"
if [ -n "$BREW_PACKAGES" ]; then
	brew install $BREW_PACKAGES
fi

echo "Fixing permissions"
sudo chown -R "$(id -u):$(id -g)" "$HOME"/workspace
sudo chown -R "$(id -u):$(id -g)" "$HOME"/.config
sudo chown -R "$(id -u):$(id -g)" "$HOME"/.local/share 

exec "$@"
