FROM ubuntu:latest

# Set environment variables
ENV HOME=/home/agent
ENV TZ=Etc/UTC

# Remove ubuntu user and home
RUN rm -rf /root && \
    userdel --remove ubuntu

# Create user "agent" and home
# This user will have root access via passwordless sudo
RUN useradd agent --uid 1000 --home-dir "$HOME" --create-home && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/agent && \
    chmod 0440 /etc/sudoers.d/agent

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

# Install homebrew (using tar for small size)
RUN sudo mkdir -p /home/linuxbrew/.linuxbrew && \
    sudo chown -R "$(id -u):$(id -g)" /home/linuxbrew/.linuxbrew && \
    curl -L https://github.com/Homebrew/brew/tarball/main | \
    tar xz --strip-components 1 -C /home/linuxbrew/.linuxbrew

# Set required homebrew environment variables
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chown agent:agent /entrypoint.sh \
    chmod +x /entrypoint.sh

# Change to "agent" user
USER agent
WORKDIR "$HOME"

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

# Create some standard folders
RUN mkdir -p \
    ~/.config \
    ~/.local \
    ~/workspace

ENTRYPOINT ["/entrypoint.sh", "/bin/bash"]
