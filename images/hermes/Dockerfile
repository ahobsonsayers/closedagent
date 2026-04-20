FROM arranhs/closedagent:latest

ARG HERMES_VERSION=2026.4.16

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    ripgrep && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hermes

# Install hermes
RUN git clone --branch "v$HERMES_VERSION" --depth 1 --recursive \
      https://github.com/NousResearch/hermes-agent.git . && \
    uv venv && \
    uv pip install ".[messaging,cron,cli,mcp]" && \
    chown agent:agent -R /opt/hermes && \
    ln -sf /opt/hermes/.venv/bin/hermes /usr/local/bin/hermes

USER agent

WORKDIR $HOME

CMD ["hermes"]
