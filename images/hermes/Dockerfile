FROM arranhs/closedagent:latest

ARG HERMES_VERSION=2026.4.16

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    ripgrep && \
    rm -rf /var/lib/apt/lists/*

USER agent

# Clone Hermes
RUN git clone --branch "v$HERMES_VERSION" --depth 1 --recursive \
    https://github.com/NousResearch/hermes-agent.git \
    ~/.hermes/hermes-agent

# Install Hermes
RUN cd ~/.hermes/hermes-agent && \
    uv venv && \
    uv pip install ".[messaging,cron,cli,mcp]" && \
    ln -sf ~/.hermes/hermes-agent/.venv/bin/hermes ~/.local/bin/hermes

CMD ["hermes"]
