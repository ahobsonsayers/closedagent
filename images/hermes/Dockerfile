ARG HERMES_VERSION=v2026.6.5

FROM oven/bun:alpine AS frontend-builder

ARG HERMES_VERSION

RUN apk add --no-cache git

RUN git clone --branch "$HERMES_VERSION" --depth 1 \
      https://github.com/NousResearch/hermes-agent.git /hermes

WORKDIR /hermes/web

RUN bun install --frozen-lockfile
RUN bun run build

FROM arranhs/closedagent:latest

ARG HERMES_VERSION

ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    ripgrep && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hermes

# Install hermes
RUN git clone --branch "$HERMES_VERSION" --depth 1 \
      https://github.com/NousResearch/hermes-agent.git . && \
    uv venv && \
    uv pip install --no-cache-dir -e ".[cli,messaging,mcp,cron,web,pty]" && \
    uv pip install --no-cache-dir hindsight-client honcho && \
    chown agent:agent -R /opt/hermes && \
    ln -sf /opt/hermes/.venv/bin/hermes /usr/local/bin/hermes

COPY --from=frontend-builder --chown=agent:agent /hermes/hermes_cli/web_dist /opt/hermes/hermes_cli/web_dist

WORKDIR $HOME

# Setup home
RUN mkdir -p "$HOME/.hermes" && \
    chown agent:agent -R "$HOME"

VOLUME "$HOME/.hermes"

CMD ["hermes"]
