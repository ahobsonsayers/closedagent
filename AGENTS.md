# AGENTS.md

This is a Docker image monorepo building sandboxed environments for AI agents.

## Images

| Image | Description | Dockerfile |
|-------|-------------|------------|
| `closedagent` | Base image with dev tools | `images/closedagent/Dockerfile` |
| `opencode` | opencode sandbox | `images/opencode/Dockerfile` |
| `openchamber` | Web UI for opencode | `images/openchamber/Dockerfile` |
| `hermes` | Hermes agent from Nous Research | `images/hermes/Dockerfile` |

## Commands

```bash
# Build all images
docker build ./images/closedagent --tag arranhs/closedagent:latest

# Build specific image
docker build ./images/opencode --tag arranhs/opencode:latest

# Run with compose
docker compose -f images/closedagent/compose.yaml up

# Connect to running container
docker exec -it closedagent /bin/bash
```

## Developer Commands (Taskfile.yaml)

```bash
task format     # Format shell scripts with shfmt
task lint       # Lint shell scripts with shellcheck
task build      # Build closedagent image
task run        # Run with docker compose
task connect    # Connect to running container
```

## Development Notes

- **User**: Container runs as `agent` (UID 1000), not root. Uses `gosu` to drop privileges.
- **Entrypoint**: Scripts in `/entrypoint.d/` run at startup before the main command.
- **Package installation**: Set `BREW_PACKAGES`, `NPM_TOOLS`, `PYTHON_TOOLS`, or `APT_PACKAGES` env vars at runtime.
- **Shell scripts**: Use `bash` with `set -euo pipefail`. Format with `shfmt`, lint with `shellcheck`.