#!/usr/bin/env bash
set -euo pipefail

for script in /entrypoint.d/*; do
  if [[ -f $script ]]; then
    sudo chmod -R 0755 "$script" 2> /dev/null || true
    "$script"
  fi
done

echo "Running:"
echo "$@"
echo

exec "$@"
