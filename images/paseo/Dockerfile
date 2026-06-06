ARG AGENT_IMAGE

FROM $AGENT_IMAGE

ARG PASEO_VERSION=0.1.90

ENV PASEO_LISTEN=0.0.0.0:6767

# Install paseo
RUN bun install --global @getpaseo/cli@$PASEO_VERSION

# Setup persistence
RUN mkdir -p "$HOME/.paseo" && \
    chown agent:agent -R "$HOME/.paseo"

VOLUME "$HOME/.paseo"

CMD ["paseo", "daemon", "start", "--foreground"]
