FROM debian:stable-slim

# Set environment variables
ENV HOME=/home/agent
ENV TZ=Etc/UTC

# Install apt packages
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    fd-find \
    findutils \
    git \
    grep \
    jq \
    nodejs \
    openssh-client \
    python3 \
    sed \
    tar \
    tini \
    unzip \
    util-linux \
    wget \
    zip && \
    rm -rf /var/lib/apt/lists/*

# Remove root directory
RUN rm -rf /root

# Create "agent" user and home
RUN useradd agent --uid 1000 --home-dir "$HOME" --create-home

# Install gosu
COPY --chmod=0755 --from=tianon/gosu:debian /gosu /usr/local/bin/gosu

# Install docker cli and plugins (buildx, compose)
COPY --chmod=0755 --from=docker:cli /usr/local/bin/docker /usr/local/bin/
COPY --chmod=0755 --from=docker:cli /usr/local/libexec/docker/cli-plugins/ /usr/local/libexec/docker/cli-plugins/

# Install homebrew (using tar for small size)
RUN mkdir -p /home/linuxbrew/.linuxbrew && \
    curl -L --progress-bar https://github.com/Homebrew/brew/tarball/main | \
    tar xz --strip-components 1 -C /home/linuxbrew/.linuxbrew && \
    chown -R agent:agent /home/linuxbrew

# Set required homebrew environment variables
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV HOMEBREW_CACHE="$HOME/.cache/homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Install uv
COPY --chmod=0755 --from=ghcr.io/astral-sh/uv:debian /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/
ENV UV_CACHE_DIR="$HOME/.cache/uv"

# Copy entrypoint scripts
COPY ./scripts/entrypoint.sh /entrypoint.sh
COPY ./entrypoint.d /entrypoint.d

RUN \ 
    # Create some standard folders
    mkdir -p \
      "$HOME/.cache" \    
      "$HOME/.config" \
      "$HOME/.local/bin" \
      "$HOME/.local/share" \
      "$HOME/.npm" && \
    # Fix permissions
    chmod -R 0755 /entrypoint.sh /entrypoint.d && \
    chown -R agent:agent "$HOME"

ENV PATH=$HOME/.local/bin:$HOME/.npm/bin:$PATH
ENV NPM_CONFIG_PREFIX=$HOME/.npm
ENV NPM_CONFIG_CACHE=$HOME/.cache/npm

WORKDIR "$HOME"

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
CMD bash
