# OpenCode

OpenCode is a docker image for running [opencode](https://github.com/anomalyco/opencode) in an isolated sandboxed environment.

## Why? <!-- omit from toc -->

[opencode](https://github.com/anomalyco/opencode) is an awesome tool for writing code and improving productivity. It is very powerful, but in the words of Uncle Ben - "With great power, comes great responsibility".

So naturally, it is therefore a good idea to run opencode in an isolated sandboxed environment - such as a docker container.

While this is not a perfect solution, it significantly reduces the blast radius when it does something dumb, particularly when running with "YOLO" permissions - no one wants to see `rm -rf /` being executed on their host machine!

## Contents <!-- omit from toc -->

- [Usage](#usage)
- [Web UI](#web-ui)
  - [Environment Variables](#environment-variables)
- [Extending](#extending)

## Usage

By default, when the container is run, it will run the `opencode` command with no args in the default working directory `/home/agent/workspace`.

To get started quickly, simply mount your folder to this directory.

For your current working directory, this command is:

```bash
docker run -it --rm -v "$(pwd):/home/agent/workspace" arranhs/opencode:latest
```

## Web UI

It is also possible to run the opencode Web UI for development on the go or in your local browser.

To do this, using docker Compose is recommended to easily run the service in the background.

To run the Web UI using all the previously mentioned mounts, you can create a `compose.yaml` with the following content:

```yaml
services:
  opencode:
    container_name: opencode
    image: arranhs/opencode:latest
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
