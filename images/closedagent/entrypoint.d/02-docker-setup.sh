#!/usr/bin/env bash
set -euo pipefail

# Check if docker socket is mounted
# If socket is not mounted, skip setup
[[ -S /var/run/docker.sock ]] || exit 0

echo "Docker socket mounted. Setting up permissions."

DOCKER_SOCKET_GID=$(stat -c '%g' /var/run/docker.sock)

# Create 'docker' group with gid of docker socket
sudo groupadd -g "$DOCKER_SOCKET_GID" docker

# Add 'agent' user to 'docker' group
sudo usermod -aG docker agent
