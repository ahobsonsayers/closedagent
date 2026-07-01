FROM arranhs/closedagent:latest

ARG PI_VERSION=0.80.3

# Install pi
RUN bun install --global --ignore-scripts @earendil-works/pi-coding-agent@$PI_VERSION

# Setup home
RUN mkdir -p "$HOME/.pi" && \
    chown agent:agent -R "$HOME"

VOLUME "$HOME/.pi"

CMD pi
