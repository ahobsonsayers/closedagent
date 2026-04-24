FROM arranhs/opencode:1.14.22

ARG OPENCHAMBER_VERSION=1.9.8

ENV OPENCHAMBER_HOST=0.0.0.0
ENV OPENCHAMBER_PORT=3000

# Install openchamber
# This contains a nasty hack to work around bun arbitrarily hanging on arm
# bun install is attempted multiple times if the command doesnt complete in a certain time
RUN for i in $(seq 1 5); do \
    timeout 20s bun install --global @openchamber/web@$OPENCHAMBER_VERSION && exit 0; \
    done; exit 1

CMD openchamber serve && openchamber logs
