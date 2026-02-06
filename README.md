# **ClosedAgent**

A base docker image designed to be used to create isolated sandboxed environments for running LLM/AI agents like [opencode](https://github.com/anomalyco/opencode) and [openclaw](https://github.com/openclaw/openclaw)

This is the base image for the closedagent ecosystem, and is used as the base image for [closedcode](https://github.com/ahobsonsayers/closedcode), [closedclaw](https://github.com/ahobsonsayers/closedclaw), and [closedchamber](https://github.com/ahobsonsayers/closedchamber) images

## **Why?**

LLM/AI agents are awesome for automation and improving productivity. They are very powerful, but in the words of Uncle Ben - "With great power, comes great responsibility".

The responsible thing to do when using these agents is to run them in isolated sandboxed environments such as a docker container.

While this is not a perfect solution, it significantly reduces the blast radius when they do something dumb - no-one wants to see `rm -rf /` being executed on their host machine.

This image is therefore designed to be an easy-to-use, extensible, and batteries-included base to build other images upon which different agents run

## **Features**

- Batteries included - comes with most of the standard tools that agents typically use and need. This includes core utils, git, and ssh as expected, but also bun and gh (GitHub CLI).
- Extensible - Supports installation of extra tools, packages and programming languages from either `brew` (recommended) or `apt` at runtime
- Does not run as root - agents shouldn't need to run as superuser, but has...
- Passwordless sudo - for those rare occasions you _do_ need root
- Surprisingly Small - despite all the above, the image is only ~500MB

## **Usage**

To use this base image simply specify it in the `FROM` of your docker.

In this base image:

- User is `agent` with UID `1000` and GUID `1000`
- Home is `/home/agent`
- Working directory is `/home/agent` - but during runtime it is recommended to change it to `/home/agent/workspace`. See runtime section for more info

### **Entrypoint**

It is recommended not to overwrite the `ENTRYPOINT` of this base image, as by default it will do some initialisation (such as installing additional packages - see below), and then run `/bin/bash`. Instead, it is suggested to change the `CMD` of your Docker image to modify the command that gets run during image start.

If you do want to modify the `ENTRYPOINT`, you should make sure to run `/entrypoint.sh <command>` to run the initialisation before your command

For example, if you want to run python at start, modify ENTRYPOINT to be:

```dockerfile
ENTRYPOINT ["/ENTRYPOINT.sh", "python"]
```

### **Installing** `apt` **packages**

If you need to install new packages from `apt` during image build, use `sudo`.

Alternatively, change to root using `USER root` - but don't forget to change back to the `agent` user (using `USER agent`) once you no longer need root

## **Runtime**

### **Workspace**

This image expects that the workspace for the agent will be in the `/home/agent/workspace` folder, and as part of the initialisation the container will make sure the files in this folder have the correct permissions.

Therefore it is recommended that users of any image based on this base image, mount workspace files to `/home/agent/workspace`

As part of this it is also suggested that images use this folder as the working directory using `WORKDIR` in their dockerfile

### **Installing packages**

Any image based on this base image has the ability to install additional packages from `apt` or brew at container startup simply by using environment variables.

This is useful for when your user might need programming languages or tools that aren't included in your image, to be unopinionated and keep it small

To utilize this feature, set:

- `APT_PACKAGES` environment variable to install `apt` packages
- `BREW_PACKAGES` environment variable to install `brew` packages (recommended)

Packages should be space separated, so it is important that the values are quoted.
