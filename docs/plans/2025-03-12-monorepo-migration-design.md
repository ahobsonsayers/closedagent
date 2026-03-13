# Monorepo Migration Design: OpenCode Integration

## Overview

Migrate the `../closedcode` repository into `closedagent` to create a unified monorepo. The opencode service will be a top-level folder with its own Dockerfile, compose configuration, and workflows.

## Goals

1. **Single Repository**: Manage both closedagent and opencode Docker images in one monorepo
2. **Maximize Workflow Reuse**: Create a reusable Docker build workflow shared between services
3. **Maintain Isolation**: Keep opencode-specific logic (version updates) contained
4. **Clean History**: Copy files without git history from closedcode

## Repository Structure

```
closedagent/
├── .github/
│   └── workflows/
│       ├── docker-build.yaml          (reusable workflow)
│       ├── build-closedagent.yaml     (calls docker-build)
│       └── build-opencode.yaml        (calls docker-build)
├── Dockerfile                         (closedagent base image)
├── compose.yaml
├── entrypoint.d/
├── scripts/
├── opencode/                          (new opencode folder)
│   ├── Dockerfile                     (FROM closedagent, installs opencode)
│   ├── compose.yaml                   (opencode web ui compose)
│   ├── README.md
│   └── .github/
│       └── workflows/
│           └── update.yaml            (opencode version updates)
└── [other existing files]
```

## Design Decisions

### Directory Layout
- **opencode/**: Top-level folder (renamed from closedcode)
- Each service is self-contained with its own Dockerfile and assets

### Workflow Architecture
- **docker-build.yaml**: Reusable workflow accepting:
  - `image_name`: Docker image name (e.g., `arranhs/closedagent`)
  - `context_path`: Build context (root or `opencode/`)
  - `trigger_paths`: Paths that trigger builds
  - `tag_strategy`: `calver` or `opencode-version`
- **build-closedagent.yaml**: Calls docker-build with calver tags
- **build-opencode.yaml**: Calls docker-build with opencode version tags
- **update.yaml**: Stays in opencode/.github/workflows/ for version updates

### Docker Image Hierarchy
```
debian:stable-slim
  ↓
closedagent (base image with tools)
  ↓
opencode (installs opencode-ai package)
```

### File Copy Approach
- Copy files only (no git history)
- Closedcode repository is read-only source
- Maintain file permissions and structure

## Workflow Reuse Strategy

The reusable `docker-build.yaml` workflow provides:
- Multi-platform builds (amd64/arm64)
- GitHub Actions cache integration
- Docker Hub login and push
- Digest aggregation for multi-arch images
- Flexible tagging (calver for closedagent, version number for opencode)

Service-specific workflows configure:
- Image name
- Context path
- Trigger paths
- Tag strategy
- Schedule (closedagent: weekly, opencode: daily)

## Implementation Phases

1. Create opencode/ directory structure
2. Copy files from ../closedcode
3. Create reusable docker-build.yaml workflow
4. Refactor existing closedagent build workflow
5. Create opencode build workflow
6. Copy opencode update workflow
7. Test builds for both images

## Success Criteria

- Both Docker images build successfully
- Workflows trigger on correct paths
- Tags applied correctly (calver vs version)
- Version update workflow works independently
- No broken references or paths
