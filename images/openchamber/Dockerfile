FROM arranhs/opencode:1.2.15

ARG OPENCHAMBER_VERSION=1.9.3

USER root

# Install additional apt packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 && \
    rm -rf /var/lib/apt/lists/*

USER agent

# Install openchamber
# This contains a nasty hack to work around bun arbitrarily hanging on arm
# bun install is attempted multiple times if the command doesnt complete in a certain time
RUN for i in $(seq 1 5); do \
    timeout 20s bun install --global @openchamber/web@$OPENCHAMBER_VERSION && exit 0; \
    done; exit 1

CMD openchamber serve && openchamber logs
