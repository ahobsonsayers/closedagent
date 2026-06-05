#!/usr/bin/env bash
set -euo pipefail

echo "export PATH="$PATH"" | tee -a /etc/profile > /dev/null

echo "Fixing ownership"

fast_chown() {
  find "$1" ( ! -uid 1000 -o ! -gid 1000 ) -exec chown 1000:1000 {} +
}

fast_chown "$HOME/.cache" || true
fast_chown "$HOME/.config" || true
fast_chown "$HOME/.local" || true

echo
