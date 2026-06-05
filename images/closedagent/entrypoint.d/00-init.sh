#!/usr/bin/env bash
set -euo pipefail

echo "export PATH=\"$PATH\"" | tee -a /etc/profile > /dev/null

echo "Fixing ownership"

fast_chown() {
  chown 1000:1000 "$1"
  fdfind --hidden --no-ignore --owner '!1000:' . "$1" -X chown 1000:1000
}

fast_chown "$HOME/.cache" || true
fast_chown "$HOME/.config" || true
fast_chown "$HOME/.local" || true

echo