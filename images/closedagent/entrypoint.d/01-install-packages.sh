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
  sudo apt-get install -y $(strip_quotes "$APT_PACKAGES")
  sudo rm -rf /var/lib/apt/lists/*
  echo
fi

if [[ -n ${BREW_PACKAGES:-} ]]; then
  echo "Installing brew packages"
  brew install $(strip_quotes "$BREW_PACKAGES")
  echo
fi

if [[ -n ${NPM_TOOLS:-} ]]; then
  echo "Installing npm tools"
  bun install -g $(strip_quotes "$NPM_TOOLS")
  echo
fi

if [[ -n ${PYTHON_TOOLS:-} ]]; then
  echo "Installing python tools"
  uv tool install --reinstall $(strip_quotes "$PYTHON_TOOLS")
  echo
fi
