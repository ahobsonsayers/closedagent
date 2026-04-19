# ClosedAgent

ClosedAgent is a base docker image designed to be used to create isolated sandbox environments for running LLM/AI agents like Claude Code, [opencode](https://github.com/anomalyco/opencode) and [openclaw](https://github.com/openclaw/openclaw).

## Why? <!-- omit from toc -->

LLM/AI agents are great tools for automation and improving productivity. They are super powerful! But to quote Uncle Ben - "With great power, comes great responsibility".

Therefore it is a very good idea to run these agents in an isolated sandbox environment - such as a docker container.

While this is not a perfect solution, it significantly reduces the blast radius when they do something dumb - no one wants to see `rm -rf /` being executed on their host machine!

This image is designed to be an easy-to-use, extensible, and batteries-included base to build other images upon which different agents run.

## Contents <!-- omit from toc -->

- [Features](#features)
- [Monorepo](#monorepo)
- [Usage (for building)](#usage-for-building)
  - [Working Directory](#working-directory)
  - [Entrypoint](#entrypoint)
  - [Installing `apt` packages during build](#installing-apt-packages-during-build)
- [Running](#running)
  - [Mounting Credentials](#mounting-credentials)
  - [Workspace](#workspace)
  - [Installing Additional Packages](#installing-additional-packages)
    - [Persisting Package Installations](#persisting-package-installations)
- [OpenCode Image](#opencode-image)
  - [Usage](#usage)
  - [Web UI](#web-ui)
    - [Environment Variables](#environment-variables)
- [OpenChamber Image](#openchamber-image)
  - [Usage](#usage-1)

## Features

- Batteries included - comes with most of the standard tools that agents typically use and need. This includes core utils, git, and ssh as expected, but also bun, python3, and uv.
- Extensible - Supports installation of extra tools, packages and programming languages from either `brew` (recommended), `npm` (tools), `uv` (python tools) or `apt` at runtime.
- Surprisingly Small - despite all the above, the image is only ~200MB compressed.
- Does not run as root - agents shouldn't need to run as superuser. This being said, the image does have...
- Passwordless sudo - for those rare occasions you _do_ need root.

## Monorepo

This repository contains:

- **closedagent**: Base Docker image with development tools
- **opencode**: OpenCode AI sandboxed Docker image (extends closedagent)
- **openchamber**: OpenChamber web UI for OpenCode (extends opencode)
- **hermes**: Hermes Agent from Nous Research (extends closedagent)

All images are built using reusable GitHub Actions workflows.

## Usage (for building)

To use this base image simply specify it in the `FROM` of your Dockerfile.

In this base image:

- User is `agent` with UID `1000` and GID `1000`
- Home is `/home/agent`
- Working directory is `/home/agent/workspace`

### Working Directory

This image expects that the workspace for any agent will be in the `/home/agent/workspace` folder, and as part of the initialisation the container will make sure the files in this folder have the correct permissions.

Therefore this base image sets this folder as the working directory using `WORKDIR`. It is recommended that any image based on this base image keeps this working directory in their final image.

### Entrypoint

It is recommended not to overwrite the `ENTRYPOINT` of this base image, as by default it will do some initialisation (such as installing additional packages - see below), and then run the command specified by `CMD`.

The default `CMD` is `["bash"]`, meaning the container will start an interactive bash shell. To change what runs when the container starts, you should update `CMD`, not `ENTRYPOINT`.

For example, the opencode image uses:

```dockerfile
CMD ["opencode"]
```

If you do want to modify the `ENTRYPOINT`, you should use `tini` and the entrypoint script to ensure proper initialisation. For example:

```dockerfile
ENTRYPOINT ["tini", "--", "/entrypoint.sh", "<command>"]
```

### Installing `apt` packages during build

If you need to install new packages from `apt` during image build, use `sudo`.

Alternatively, change to root using `USER root` - but don't forget to change back to the `agent` user (using `USER agent`) once you no longer need root.

## Running

To run agent images based on this base image, it is recommended to use docker compose. This simplifies much of the configuration/settings needed to run an image, such as the command, volumes and environment variables.

An example docker compose which runs this base image and then sleeps infinitely, can be seen in [`images/closedagent/compose.yaml`](images/closedagent/compose.yaml).

Using this docker compose, you can then easily run the image in the background with:

```bash
docker compose up -d
```

Once the image is running it is possible to connect to the container and execute any command from within it with:

```bash
docker exec -it closedagent <your-command>
```

### Mounting Credentials

Most agents (including opencode) need access to your SSH keys for code operations:

```yaml
services:
  agent:
    volumes:
      - ~/.gitconfig:/home/agent/.gitconfig     # Git configuration
      - ~/.ssh:/home/agent/.ssh                 # SSH keys
```

### Workspace

The default workspace for agents run using this image is `/home/agent/workspace`.

Therefore when using any image based on this base image, you should mount your workspace files to `/home/agent/workspace`.

### Installing Additional Packages

Any image based on this base image has the ability to install additional tools from `brew`, `npm`, `uv` (python tools) or `apt` at container startup by using environment variables.

This is useful for when you need to install tools or programming languages etc. that aren't included in the image by default.

To utilize this feature, set:

- `BREW_PACKAGES` environment variable to install `brew` packages (recommended)
- `NPM_TOOLS` environment variable to install `npm` tools globally
- `PYTHON_TOOLS` environment variable to install python tools globally using `uv tool install`
- `APT_PACKAGES` environment variable to install `apt` packages

Packages should be space separated, so it may be required to quote the values.

> [!WARNING]
> Installing via apt is not recommended as installations cannot be easily persisted (see below). This means packages will need to be reinstalled on every run, which can make startup slow.

#### Persisting Package Installations

Installing packages on container run can make startup slow.

To speed up container start (after the initial run), it is possible to persist the package manager caches by mounting docker volumes:

This is done by the following volumes which can be seen in [`images/closedagent/compose.yaml`](images/closedagent/compose.yaml)

```yaml
volumes:
  - brew-cache:/home/agent/.cache/Homebrew
  - bun-cache:/home/agent/.bun/install/cache
  - uv-cache:/home/agent/.cache/uv
  - apt-cache:/var/cache/apt/archives
```

These lines persist download caches (not full installations) for each package manager. Tools are still installed on each container start, but packages are fetched from cache when available.

> **Tip:** It is recommended to only mount the caches as shown above. While you *can* mount the actual installation directories for faster startup (e.g., `/home/linuxbrew`, `/home/agent/.bun`), this may cause unforeseen or hard-to-debug issues.

## OpenCode Image

The `opencode` image extends `closedagent` and provides a sandboxed environment for running [opencode](https://github.com/anomalyco/opencode).

### Usage

By default, when the container is run, it will run the `opencode` command with no args in the default working directory `/home/agent/workspace`.

To get started quickly, simply mount your folder to this directory.

For your current working directory, this command is:

```bash
docker run -it --rm -v "$(pwd):/home/agent/workspace" arranhs/opencode:latest
```

### Web UI

It is also possible to run the opencode Web UI for development on the go or in your local browser.

To do this, using Docker Compose is recommended to easily run the service in the background. An example compose file can be found at [`images/opencode/compose.yaml`](images/opencode/compose.yaml).

Run with:

```bash
docker compose up -d
```

#### Environment Variables

When running the Web UI, the following env vars can be set to configure authentication.

- `OPENCODE_SERVER_USERNAME` - Username for Web UI authentication (Default: `opencode`)
- `OPENCODE_SERVER_PASSWORD` - Password for Web UI authentication (Default: not set/no auth)

## OpenChamber Image

The `openchamber` image extends `opencode` and provides a sandboxed environment for running [openchamber](https://github.com/btriapitsyn/openchamber) - a feature-rich web UI for developing with opencode.

### Usage

By default, when the container is run, it will start the OpenChamber web UI on port 3000.

Using Docker Compose is recommended to easily run the service. An example compose file can be found at [`images/openchamber/compose.yaml`](images/openchamber/compose.yaml).

Run with:

```bash
docker compose up -d
```

Then access the web UI at http://localhost:3000.

The compose file mounts:
- Your code workspace to `/home/agent/workspace`
- OpenChamber config to `/home/agent/.config/openchamber`
- OpenCode config and data for persistence
- Git config

## Hermes Image

The `hermes` image extends `closedagent` and provides a sandboxed environment for running [Hermes Agent](https://hermes-agent.nousresearch.com/) - an autonomous agent from Nous Research that grows with you.

### Usage

By default, when the container is run, it will start the Hermes gateway.

Using Docker Compose is recommended to easily run the service. An example compose file can be found at [`images/hermes/compose.yaml`](images/hermes/compose.yaml).

Run with:

```bash
docker compose up -d
```

The compose file mounts:
- Your code workspace to `/home/agent/workspace`
- Hermes config to `/home/agent/.config/hermes`
- Hermes data to `/home/agent/.local/share/hermes`
- Git config and SSH keys for code operations
