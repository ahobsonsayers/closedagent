FROM ubuntu:latest

# Set environment variables
ENV HOME=/home/agent
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

# Remove ubuntu user and home
RUN rm -rf /root && \
    userdel --remove ubuntu

# Create "agent" user and home
# This user will have root access via passwordless sudo
RUN useradd agent --uid 1000 --home-dir "$HOME" --create-home && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/agent && \
    chmod 0440 /etc/sudoers.d/agent

# Copy entrypoint scripts
COPY ./entrypoint.sh /entrypoint.sh
COPY ./entrypoint.d /entrypoint.d

RUN \ 
    # Create some standard folders
    mkdir -p \
    "$HOME/workspace" \
    "$HOME/.config" \
    "$HOME/.local/bin" \
    "$HOME/.local/share" && \
    # Fix permissions
    chown -R agent:agent \
    /entrypoint.sh \
    /entrypoint.d \
    "$HOME" && \
    # Make entrypoint scripts executable
    chmod +x /entrypoint.sh /entrypoint.d/*

# Install homebrew (using tar for small size)
RUN mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R agent:agent /home/linuxbrew/.linuxbrew && \
    curl -L https://github.com/Homebrew/brew/tarball/main | \
    tar xz --strip-components 1 -C /home/linuxbrew/.linuxbrew

# Set required homebrew environment variables
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Change to "agent" user
USER agent
WORKDIR "$HOME"

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

# Add .local bin to path
ENV PATH=$HOME/.local/bin:$PATH

# Set working directory
WORKDIR "$HOME/workspace"

ENTRYPOINT ["/entrypoint.sh", "/bin/bash"]
