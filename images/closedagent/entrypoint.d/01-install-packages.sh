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

if [[ -n ${APT_PACKAGES:-} ]]; then
	echo "Installing apt packages"
	sudo apt-get update
	# shellcheck disable=SC2046
	sudo apt-get install -y $(strip_quotes "$APT_PACKAGES")
	sudo rm -rf /var/lib/apt/lists/*
	echo
fi

if [[ -n ${BREW_PACKAGES:-} ]]; then
	echo "Installing brew packages"
	# shellcheck disable=SC2046
	brew install $(strip_quotes "$BREW_PACKAGES")
	echo
fi

if [[ -n ${NPM_TOOLS:-} ]]; then
	echo "Installing npm tools"
	# shellcheck disable=SC2046
	bun install -g $(strip_quotes "$NPM_TOOLS")
	echo
fi

if [[ -n ${PYTHON_TOOLS:-} ]]; then
	echo "Installing python tools"
	# shellcheck disable=SC2046
	uv tool install $(strip_quotes "$PYTHON_TOOLS")
	echo
fi
