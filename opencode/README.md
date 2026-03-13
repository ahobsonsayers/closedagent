# OpenCode

OpenCode is a docker image for running [opencode](https://github.com/anomalyco/opencode) in an isolated sandboxed environment.

## Why? <!-- omit from toc -->

[opencode](https://github.com/anomalyco/opencode) is an awesome tool for writing code and improving productivity. It is very powerful, but in the words of Uncle Ben - "With great power, comes great responsibility".

So naturally, it is therefore a good idea to run opencode in an isolated sandboxed environment - such as a docker container.

While this is not a perfect solution, it significantly reduces the blast radius when it does something dumb, particularly when running with "YOLO" permissions - no one wants to see `rm -rf /` being executed on their host machine!

## Contents <!-- omit from toc -->

- [Features](#features)
- [Usage](#usage)
- [Persistence and Volumes](#persistence-and-volumes)
- [Other files e.g. git, gh etc.](#other-files-eg-git-gh-etc)
- [Installing Additional Packages](#installing-additional-packages)
  - [Why is installation by `brew` recommended?](#why-is-installation-by-brew-recommended)
- [Web UI](#web-ui)
  - [Environment Variables](#environment-variables)
- [Extending](#extending)

## Features

There are a few docker images for opencode out there, so what makes this one different?

- Batteries included - comes with most of the standard tools that agents typically use and need. This includes core utils, git, and ssh as expected, but also bun and gh (GitHub CLI).
- Extensible - Supports installation of extra tools, packages and programming languages from either `brew` (recommended) or `apt` at runtime
- Surprisingly Small - despite all the above, the image is only ~400MB compressed
- Does not run as root - agents shouldn't need to run as superuser, but has...
- Passwordless sudo - for those rare occasions you _do_ need root

## Usage

By default, when the container is run, it will run the `opencode` command with no args in the default working directory `/home/agent/workspace`.

To get started quickly, simply mount your folder to this directory.

For your current working directory, this command is:

```bash
docker run -it --rm -v "$(pwd):/home/agent/workspace" arranhs/opencode:latest
```

## Persistence and Volumes

By default, both opencode config and opencode sessions will be persisted across runs of the container; however, you might want to mount these to your host machine if you want easy access to the config files (for editing), or if you want to share config and state with opencode that you might run outside of this sandbox.

To mount these folders, you can run:

```bash
docker run -it --rm \
  -v "$(pwd):/home/agent/workspace" \
-v "<config-path>:/home/agent/.config/opencode" \
  -v "<data-path>:/home/agent/.local/share/opencode" \
arranhs/opencode:latest
```

For example, if you want to use config and data used by opencode running on your local machine, run:

```bash
docker run -it --rm \
  -v "$(pwd):/home/agent/workspace" \
-v "$HOME/.config/opencode:/home/agent/.config/opencode" \
  -v "$HOME/.local/share/opencode:/home/agent/.local/share/opencode" \
arranhs/opencode:latest
```

## Other files e.g. git, gh etc.

To get the most out of opencode running in this sandbox, it is likely you also want to mount additional files from your local machine - such as your git config and GitHub credentials from using the GitHub CLI (using the `gh` CLI to auth with GitHub is highly recommended for ease).

For these files, it is recommended to mount them as read-only.

To do this, you can run opencode with:

```bash
docker run -it --rm \
  -v "$(pwd):/home/agent/workspace" \
-v "$HOME/.config/opencode:/home/agent/.config/opencode" \
  -v "$HOME/.local/share/opencode:/home/agent/.local/share/opencode" \
-v "$HOME/.gitconfig:/home/agent/.gitconfig:ro" \
  -v "$HOME/.ssh:/home/agent/.ssh:ro" \
-v "$HOME/.config/gh:/home/agent/.config/gh:ro" \
  arranhs/opencode:latest
```

## Installing Additional Packages

You can install additional packages at container startup using environment variables.

This is useful when you need languages or tools that aren't included in the base image.

You can set:

- `APT_PACKAGES` environment variable to install `apt` packages
- `BREW_PACKAGES` environment variable to install `brew` packages (recommended)

Packages should be space separated, so remember to quote your values.

For example, you can run:

```bash
docker run -it --rm \
  -v "$(pwd):/home/agent/workspace" \
-e "APT_PACKAGES=python3" \
  -e "BREW_PACKAGES=node go" \
arranhs/opencode:latest
```

### Why is installation by `brew` recommended?

Homebrew has a huge array of tools and packages (~7000), many of which are missing in apt. As such, Homebrew is extremely likely to have the software you require, and its cache is easy to persist, which can be leveraged to make startup installs faster. Info on this to be added.

## Web UI

It is also possible to run the opencode Web UI for development on the go or in your local browser.

To do this, using docker Compose is recommended to easily run the service in the background.

To run the Web UI using all the previously mentioned mounts, you can create a `compose.yaml` with the following content:

```yaml
services:
  opencode:
    container_name: opencode
    image: arranhs/opencode:latest
    build:
      context: .
    command: ["opencode", "web", "--hostname", "0.0.0.0", "--port", "4096"]
    restart: unless-stopped
    ports:
      - 4096:4096
    volumes:
      - ./data/workspace:/home/agent/workspace # code files
      - ./data/.config/opencode:/home/agent/.config/opencode # opencode config
      - ./data/.local/share/opencode:/home/agent/.local/share/opencode # opencode data
      - ~/.gitconfig:/home/agent/.gitconfig # git config
      - ~/.config/gh:/home/agent/.config/gh # github cli config
```

And then run with:

```bash
docker compose up -d
```

### Environment Variables

When running the Web UI, the following env vars can be set to configure authentication.

- `OPENCODE_SERVER_USERNAME` - Username for Web UI authentication (Default: `opencode`)
- `OPENCODE_SERVER_PASSWORD` - Password for Web UI authentication (Default: not set/no auth)

## Extending

This image also works well as a base image to be extended and worked upon. An example of this can be seen in the [closedchamber](https://github.com/ahobsonsayers/closedchamber) repository, which offers a docker container for running [openchamber](https://github.com/btriapitsyn/openchamber) - a feature-rich web ui for developing with opencode.
