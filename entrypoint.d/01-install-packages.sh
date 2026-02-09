#!/usr/bin/env bash
set -euo pipefail

strip_quotes() {
	local string="$1"
	string=${string#\"}
	string=${string%\"}
	string=${string#\'}
	string=${string%\'}
	echo "$string"
}

if [[ -n "${APT_PACKAGES:-}" ]]; then
	echo "Installing apt packages"
	sudo apt-get update
	sudo apt-get install -y $(strip_quotes "$APT_PACKAGES")
	sudo rm -rf /var/lib/apt/lists/*
	echo
fi

if [[ -n "${BREW_PACKAGES:-}" ]]; then
	echo "Installing brew packages"
	brew install $(strip_quotes "$BREW_PACKAGES")
	echo
fi

if [[ -n "${BUN_PACKAGES:-}" ]]; then
	echo "Installing bun packages"
	bun install -g $(strip_quotes "$BUN_PACKAGES")
	echo
fi
