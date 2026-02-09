#!/usr/bin/env bash
set -euo pipefail

for script in /entrypoint.d/*; do
	if [[ -f "$script" ]]; then
		chmod +x "$script"
		"$script"
	fi
done

exec "$@"
