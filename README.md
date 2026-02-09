# ClosedAgent

ClosedAgent is a base docker image designed to be used to create isolated sandboxed environments for running LLM/AI agents like [opencode](https://github.com/anomalyco/opencode) and [openclaw](https://github.com/openclaw/openclaw).

This is the base image for the closedagent ecosystem, and is used as the base image for [closedcode](https://github.com/ahobsonsayers/closedcode), [closedclaw](https://github.com/ahobsonsayers/closedclaw), and [closedchamber](https://github.com/ahobsonsayers/closedchamber) images.

## Why? <!-- omit from toc -->

LLM/AI agents are awesome for automation and improving productivity. They are very powerful, but in the words of Uncle Ben - "With great power, comes great responsibility."

So naturally, it is therefore a good idea to run these agents in isolated sandboxed environments - such as a docker container.

While this is not a perfect solution, it significantly reduces the blast radius when they do something dumb - no-one wants to see `rm -rf /` being executed on their host machine!

This image is designed to be an easy-to-use, extensible, and batteries-included base to build other images upon which different agents run.

## Contents <!-- omit from toc -->

- [Features](#features)
- [Usage (for building)](#usage-for-building)
  - [Working Directory](#working-directory)
  - [Entrypoint](#entrypoint)
  - [Installing `apt` packages during build](#installing-apt-packages-during-build)
- [Running](#running)
  - [Workspace](#workspace)
  - [Installing Additional Packages](#installing-additional-packages)
    - [Persisting Package Installations](#persisting-package-installations)

## Features

- Batteries included - comes with most of the standard tools that agents typically use and need. This includes core utils, git, and ssh as expected, but also bun and gh (GitHub CLI).
- Extensible - Supports installation of extra tools, packages and programming languages from either `brew` (recommended), `bun` or `apt` at runtime.
- Surprisingly Small - despite all the above, the image is only ~200MB compressed.
- Does not run as root - agents shouldn't need to run as superuser. This being said, the image does have...
- Passwordless sudo - for those rare occasions you _do_ need root.

## Usage (for building)

To use this base image simply specify it in the `FROM` of your docker.

In this base image:

- User is `agent` with UID `1000` and GUID `1000`
- Home is `/home/agent`
- Working directory is `/home/agent/workspace`

### Working Directory

This image expects that the workspace for any agent will be in the `/home/agent/workspace` folder, and as part of the initialisation the container will make sure the files in this folder have the correct permissions.

Therefore this base image sets this folder as the working directory using `WORKDIR`. It is recommended that any image based on this base image keeps this working directory in their final image.

### Entrypoint

It is recommended not to overwrite the `ENTRYPOINT` of this base image, as by default it will do some initialisation (such as installing additional packages - see below), and then run `/bin/bash`. Instead, it is suggested to change the `CMD` of your Docker image to modify the command that gets run during image start.

If you do want to modify the `ENTRYPOINT`, you should make sure to run `/entrypoint.sh <command>` to run the initialisation before your command.

For example, if you want to run python at start, modify ENTRYPOINT to be:

```dockerfile
ENTRYPOINT ["/ENTRYPOINT.sh", "python"]
```

### Installing `apt` packages during build

If you need to install new packages from `apt` during image build, use `sudo`.

Alternatively, change to root using `USER root` - but don't forget to change back to the `agent` user (using `USER agent`) once you no longer need root.

## Running

To run agent images based on this base image, it is recommended to use docker compose. This simplifies much of the configuration/settings needed to run an image, such as the command, volumes and environment variables.

An example docker compose which runs this base image and then sleeps infinitely, can be seen in [compose.example.yaml](compose.example.yaml).

Using this docker compose, you can then easily run the image in the background with:

```bash
docker compose up -d
```

Once the image is running it is possible to connect to the container and execute any command from with it with:

```bash
docker exec -it closedagent <your-command>
```

### Workspace

The default workspace for agents run using this image is `/home/agent/workspace`.

Therefore when using any image based on this base image, you should mount your workspace files to `/home/agent/workspace`.

### Installing Additional Packages

Any image based on this base image has the ability to install additional packages from `brew`, `bun` or `apt` at container startup by using environment variables.

This is useful for when you need to install tools or programming languages etc. that aren't included in the image by default.

To utilize this feature, set:

- `BREW_PACKAGES` environment variable to install `brew` packages (recommended)
- `BUN_PACKAGES` environment variable to install `bun` packages globally
- `APT_PACKAGES` environment variable to install `apt` packages

Packages should be space separated, so it may be required to quote the values.

> [!WARNING]
> Installing via apt is not recommended as installations cannot be easily persisted (see below). This means packages will need to be reinstalled on every run, which can make startup slow.

#### Persisting Package Installations

Installing packages on container run can make startup slow.

To speed up container start (after the initial run), it is possible to avoid having to re-install all packages again by mounting docker volumes to persist installations or caches:

This is done by the following volumes which can be seen in the [compose.example.yaml](compose.example.yaml)

```yaml
volumes:
  - closedagent-brew:/home/linuxbrew
  - closedagent-bun:/home/agent/.bun
  - closedagent-apt-cache:/var/cache/apt/archives
```

These lines persist:

- Homebrew package installations - future installations will be skipped
- Bun package installations - future installations will be skipped
- apt package cache - future installations will **not** be skipped as the installations cannot be easily persisted due to the design of `apt`. However, persisting the cache will speed up future installs by avoiding having to re-download packages.
