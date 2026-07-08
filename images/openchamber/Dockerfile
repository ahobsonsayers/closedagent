FROM arranhs/opencode:latest

ARG OPENCHAMBER_VERSION=1.14.1

ENV OPENCHAMBER_HOST=0.0.0.0
ENV OPENCHAMBER_PORT=3000

# Install openchamber
RUN npm install --global @openchamber/web@$OPENCHAMBER_VERSION

# Setup home
RUN mkdir -p "$HOME/.config/openchamber" && \
    chown agent:agent -R "$HOME"

VOLUME "$HOME/.config/openchamber"

CMD openchamber serve && openchamber logs
