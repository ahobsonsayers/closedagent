FROM ubuntu:latest

ENV TZ=Etc/UTC

# Install apt packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    findutils \
    gh \
    git \
    grep \
    jq \
    openssh-client \
    sed \
    sudo \
    tar \
    unzip \
    util-linux \
    wget \
    zip && \
    rm -rf /var/lib/apt/lists/*

# Remove ubuntu  user and home
RUN rm -rf /root && \
    userdel --remove ubuntu

# Create user "agent" and home
# User will have root access via sudo
RUN useradd agent --uid 1000 --home-dir /home/agent --create-home && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/agent && \
    chmod 0440 /etc/sudoers.d/agent

USER agent
ENV HOME=/home/agent

# Install homebrew (using tar for small size)
RUN sudo mkdir -p /home/linuxbrew/.linuxbrew && \
    sudo chown -R "$(id -u):$(id -g)" /home/linuxbrew/.linuxbrew && \
    curl -L https://github.com/Homebrew/brew/tarball/main | \
    tar xz --strip-components 1 -C /home/linuxbrew/.linuxbrew

# Set required homebrew envs
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

WORKDIR "$HOME/workspace"

ENTRYPOINT ["/bin/bash"]
