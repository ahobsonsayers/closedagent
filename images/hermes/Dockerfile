FROM arranhs/closedagent:latest

ARG HERMES_VERSION=0.10.0

USER root

# Install Hermes dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-venv && \
    rm -rf /var/lib/apt/lists/*

USER agent

# Install Hermes
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

CMD ["hermes", "gateway", "start"]
