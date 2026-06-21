ARG AGENT_IMAGE

FROM $AGENT_IMAGE

ARG PASEO_VERSION=0.1.98

ENV PASEO_LISTEN=0.0.0.0:6767
ENV PASEO_HOSTNAMES=true

# Install paseo
RUN bun install --global @getpaseo/cli@$PASEO_VERSION

# Setup home
RUN mkdir -p "$HOME/.paseo" && \
    chown agent:agent -R "$HOME"

VOLUME "$HOME/.paseo"

CMD ["paseo", "daemon", "start", "--foreground"]
