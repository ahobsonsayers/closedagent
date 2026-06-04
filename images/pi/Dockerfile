FROM arranhs/closedagent:latest

ARG PI_VERSION=0.78.0

# Install pi
RUN bun install --global --ignore-scripts @earendil-works/pi-coding-agent@$PI_VERSION

# Setup persistence
RUN mkdir -p "$HOME/.pi"

VOLUME "$HOME/.pi"

CMD pi
