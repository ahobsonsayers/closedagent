#!/usr/bin/env bash
set -euo pipefail

echo "export PATH=\"$PATH\"" | tee -a /etc/profile > /dev/null

if [ "${SKIP_FIX_PERMISSIONS:-}" = "true" ]; then
  echo "Skipping ownership fix (SKIP_FIX_PERMISSIONS=true)"

else
  echo "Fixing ownership (set SKIP_FIX_PERMISSIONS=true to skip)"

  fast_chown() {
    chown 1000:1000 "$1"
    fdfind --hidden --no-ignore --owner '!1000:' . "$1" -X chown 1000:1000
  }

  fast_chown "$HOME/.cache" || true
  fast_chown "$HOME/.config" || true
  fast_chown "$HOME/.local" || true
fi

echo