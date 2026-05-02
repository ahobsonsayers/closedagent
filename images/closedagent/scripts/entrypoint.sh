#!/usr/bin/env bash
set -euo pipefail

for script in /entrypoint.d/*; do
  if [[ -f $script ]]; then
    source "$script"
  fi
done

echo "Running:"
echo "$@"
echo

exec gosu agent "$@"
