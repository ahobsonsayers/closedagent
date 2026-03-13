# Monorepo Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate ../closedcode repository into closedagent as a monorepo with shared reusable Docker build workflows

**Architecture:** Create opencode/ top-level folder with its own Dockerfile (extends closedagent image), reusable docker-build workflow in .github/workflows/, and service-specific build workflows that call the reusable one with parameters.

**Tech Stack:** GitHub Actions, Docker, YAML workflows

---

### Task 1: Create opencode directory structure

**Files:**
- Create: `opencode/`
- Create: `opencode/.github/workflows/`

**Step 1: Create opencode directory**

Run: `mkdir -p opencode/.github/workflows`
Expected: Directory created successfully

**Step 2: Verify directory structure**

Run: `ls -la opencode/.github/workflows/`
Expected: Empty directory confirmed

**Step 3: Commit**

```bash
git add opencode
git commit -m "chore: create opencode directory structure"
```

---

### Task 2: Copy Dockerfile from closedcode

**Files:**
- Create: `opencode/Dockerfile`

**Step 1: Read closedcode Dockerfile**

Run (from closedagent workspace):
```bash
cat ../closedcode/Dockerfile
```

**Step 2: Create opencode/Dockerfile**

```dockerfile
FROM arranhs/closedagent:latest

ARG OPENCODE_VERSION=1.2.15

# Install opencode
RUN bun install --global opencode-ai@$OPENCODE_VERSION

ENV OPENCODE_CONFIG='{ \
        "$schema": "https://opencode.ai/config.json", \
        "autoupdate": false \
    }'

# Setup persistence
RUN mkdir -p "$HOME/.config/opencode" && \
    mkdir -p "$HOME/.local/share/opencode"

VOLUME "$HOME/.config/opencode"
VOLUME "$HOME/.local/share/opencode"

CMD ["opencode"]
```

**Step 3: Verify file created**

Run: `cat opencode/Dockerfile`
Expected: Dockerfile content matches closedcode

**Step 4: Commit**

```bash
git add opencode/Dockerfile
git commit -m "add opencode Dockerfile"
```

---

### Task 3: Copy compose.yaml from closedcode

**Files:**
- Create: `opencode/compose.yaml`

**Step 1: Read closedcode compose.yaml**

Run:
```bash
cat ../closedcode/compose.yaml
```

**Step 2: Create opencode/compose.yaml**

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
      - ./workspace:/home/agent/workspace
      - ~/.config/opencode:/home/agent/.config/opencode
      - ~/.local/share/opencode:/home/agent/.local/share/opencode
      - ~/.gitconfig:/home/agent/.gitconfig
      - ~/.config/gh:/home/agent/.config/gh
```

**Step 3: Verify file created**

Run: `cat opencode/compose.yaml`
Expected: compose.yaml with image name updated to arranhs/opencode

**Step 4: Commit**

```bash
git add opencode/compose.yaml
git commit -m "add opencode compose.yaml"
```

---

### Task 4: Copy README from closedcode

**Files:**
- Create: `opencode/README.md`

**Step 1: Read closedcode README**

Run:
```bash
cat ../closedcode/README.md
```

**Step 2: Copy content to opencode/README.md**

Run:
```bash
cp ../closedcode/README.md opencode/README.md
```

**Step 3: Update references in README**

Search and replace in opencode/README.md:
- "closedcode" -> "opencode" (except in URLs)
- "closedchamber" references remain unchanged
- "arranhs/closedcode" -> "arranhs/opencode"

**Step 4: Verify file created**

Run: `head -20 opencode/README.md`
Expected: README with updated references

**Step 5: Commit**

```bash
git add opencode/README.md
git commit -m "add opencode README"
```

---

### Task 5: Create reusable docker-build workflow

**Files:**
- Create: `.github/workflows/docker-build.yaml`

**Step 1: Create reusable workflow**

```yaml
name: Build and Push Docker Image (Reusable)

on:
  workflow_call:
    inputs:
      image_name:
        description: Docker image name (e.g., arranhs/closedagent)
        type: string
        required: true
      context_path:
        description: Build context path (e.g., . or opencode)
        type: string
        default: .
      trigger_paths:
        description: Comma-separated paths that trigger builds
        type: string
        required: true
      tag_strategy:
        description: Tag strategy (calver or opencode-version)
        type: string
        required: true
      schedule_cron:
        description: Cron schedule for automated builds
        type: string
        default: ""

env:
  DOCKER_IMAGE: ${{ inputs.image_name }}

jobs:
  get-version-info:
    name: Get version info
    runs-on: ubuntu-latest
    timeout-minutes: 10
    outputs:
      calver: ${{ steps.get-calver.outputs.calver }}
      opencode-version: ${{ steps.get-opencode-version.outputs.opencode-version }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Get CalVer
        if: inputs.tag_strategy == 'calver'
        id: get-calver
        run: |
          CALVER=$(date -u +"%Y.%m.%d")
          echo "calver=$CALVER" >> $GITHUB_OUTPUT
          echo "CalVer: $CALVER"

      - name: Get OpenCode version
        if: inputs.tag_strategy == 'opencode-version'
        id: get-opencode-version
        run: |
          OPENCODE_VERSION=$(grep "^ARG OPENCODE_VERSION=" opencode/Dockerfile | cut -d '=' -f2)
          echo "opencode-version=$OPENCODE_VERSION" >> $GITHUB_OUTPUT
          echo "OpenCode Version: $OPENCODE_VERSION"

  build:
    name: Build Image
    strategy:
      fail-fast: false
      matrix:
        include:
          - runner: ubuntu-24.04
            platform: linux/amd64
            platform-slug: linux-amd64
          - runner: ubuntu-24.04-arm
            platform: linux/arm64
            platform-slug: linux-arm64

    runs-on: ${{ matrix.runner }}
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Set up buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}

      - name: Build and push digest
        id: build
        uses: docker/build-push-action@v6
        with:
          context: ${{ inputs.context_path }}
          platforms: ${{ matrix.platform }}
          tags: ${{ env.DOCKER_IMAGE }}
          cache-from: ${{ !inputs.no-cache && 'type=gha' || '' }}
          cache-to: ${{ !inputs.no-cache && 'type=gha,mode=max' || '' }}
          outputs: type=image,push-by-digest=true,name-canonical=true,push=true

      - name: Output digest
        uses: GoCodeAlone/github-action-matrix-outputs-write@1.0.3
        with:
          matrix-step-name: build
          matrix-key: ${{ matrix.platform-slug }}
          outputs: |
            digest: ${{ steps.build.outputs.digest }}

  push-tags:
    name: Push Tags
    runs-on: ubuntu-latest
    needs: [get-version-info, build]
    timeout-minutes: 10

    steps:
      - name: Set up Buildx
        uses: docker/setup-buildx-action@v3

      - name: Get digests
        id: get-digests
        uses: GoCodeAlone/github-action-matrix-outputs-read@1.0.6
        with:
          matrix-step-name: build

      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}

      - name: Push tags with CalVer
        if: inputs.tag_strategy == 'calver'
        run: |
          DIGESTS=$(
            echo "$DIGESTS_JSON" |
            jq -r --arg docker_image "$DOCKER_IMAGE" \
              '.digest | to_entries[] | "\($docker_image)@\(.value)"'
          )

          docker buildx imagetools create \
            -t "$DOCKER_IMAGE:latest" \
            -t "$DOCKER_IMAGE:$CALVER" \
            $DIGESTS
        env:
          DIGESTS_JSON: ${{ steps.get-digests.outputs.result }}
          DOCKER_IMAGE: ${{ env.DOCKER_IMAGE }}
          CALVER: ${{ needs.get-version-info.outputs.calver }}

      - name: Push tags with version
        if: inputs.tag_strategy == 'opencode-version'
        run: |
          DIGESTS=$(
            echo "$DIGESTS_JSON" |
            jq -r --arg docker_image "$DOCKER_IMAGE" \
              '.digest | to_entries[] | "\($docker_image)@\(.value)"'
          )

          docker buildx imagetools create \
            -t "$DOCKER_IMAGE:latest" \
            -t "$DOCKER_IMAGE:$OPENCODE_VERSION" \
            $DIGESTS
        env:
          DIGESTS_JSON: ${{ steps.get-digests.outputs.result }}
          DOCKER_IMAGE: ${{ env.DOCKER_IMAGE }}
          OPENCODE_VERSION: ${{ needs.get-version-info.outputs.opencode-version }}
```

**Step 2: Verify workflow syntax**

Run: `cat .github/workflows/docker-build.yaml | head -50`
Expected: YAML syntax is valid

**Step 3: Commit**

```bash
git add .github/workflows/docker-build.yaml
git commit -m "add reusable docker-build workflow"
```

---

### Task 6: Create build-closedagent workflow

**Files:**
- Create: `.github/workflows/build-closedagent.yaml`

**Step 1: Create sealed workflow**

Read current build.yaml first:
```bash
cat .github/workflows/build.yaml
```

**Step 2: Create build-closedagent.yaml**

```yaml
name: Build and Push closedagent Image

on:
  push:
    branches:
      - main
    paths:
      - .github/workflows/build-closedagent.yaml
      - .github/workflows/docker-build.yaml
      - Dockerfile
      - entrypoint.d/**
      - scripts/**
  schedule:
    - cron: 0 0 * * 0
  workflow_dispatch:
    inputs:
      no-cache:
        description: No Cache
        type: boolean
        default: false

jobs:
  build:
    uses: ./.github/workflows/docker-build.yaml
    with:
      image_name: arranhs/closedagent
      context_path: .
      trigger_paths: ".github/workflows/build-closedagent.yaml,.github/workflows/docker-build.yaml,Dockerfile,entrypoint.d/**,scripts/**"
      tag_strategy: calver
    secrets: inherit
```

**Step 3: Verify workflow**

Run: `cat .github/workflows/build-closedagent.yaml`
Expected: Workflow calls reusable workflow with calver strategy

**Step 4: Commit**

```bash
git add .github/workflows/build-closedagent.yaml
git commit -m "add build-closedagent workflow"
```

---

### Task 7: Create build-opencode workflow

**Files:**
- Create: `.github/workflows/build-opencode.yaml`

**Step 1: Create workflow**

```yaml
name: Build and Push opencode Image

on:
  push:
    branches:
      - main
    paths:
      - .github/workflows/build-opencode.yaml
      - .github/workflows/docker-build.yaml
      - opencode/**
  schedule:
    - cron: "0 2 * * *"
  workflow_dispatch:
    inputs:
      no-cache:
        description: No Cache
        type: boolean
        default: false

jobs:
  build:
    uses: ./.github/workflows/docker-build.yaml
    with:
      image_name: arranhs/opencode
      context_path: opencode
      trigger_paths: ".github/workflows/build-opencode.yaml,.github/workflows/docker-build.yaml,opencode/**"
      tag_strategy: opencode-version
    secrets: inherit
```

**Step 2: Verify workflow**

Run: `cat .github/workflows/build-opencode.yaml`
Expected: Workflow calls reusable workflow with opencode-version strategy

**Step 3: Commit**

```bash
git add .github/workflows/build-opencode.yaml
git commit -m "add build-opencode workflow"
```

---

### Task 8: Copy opencode update workflow

**Files:**
- Create: `opencode/.github/workflows/update.yaml`

**Step 1: Read closedcode update.yaml**

Run:
```bash
cat ../closedcode/.github/workflows/update.yaml
```

**Step 2: Create opencode/.github/workflows/update.yaml**

```yaml
name: Update OpenCode Version

on:
  schedule:
    - cron: '0 1 * * *'
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update:
    name: Update version
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Get current version
        id: get-current-version
        run: |
          OPENCODE_VERSION=$(grep "^ARG OPENCODE_VERSION=" opencode/Dockerfile | cut -d '=' -f2)

          echo "opencode=$OPENCODE_VERSION" >> $GITHUB_OUTPUT

          echo "Current OpenCode Version: $OPENCODE_VERSION"

      - name: Get latest version
        id: get-latest-version
        run: |
          OPENCODE_LATEST=$(npm view opencode-ai version | tail -n 1)

          echo "opencode=$OPENCODE_LATEST" >> $GITHUB_OUTPUT

          echo "Latest OpenCode Version: $OPENCODE_LATEST"

      - name: Compare and update version
        id: compare-update
        run: |
          if [ "$CURRENT_OPENCODE_VERSION" != "$LATEST_OPENCODE_VERSION" ]; then
            echo "needs_update=true" >> $GITHUB_OUTPUT
          else
            echo "needs_update=false" >> $GITHUB_OUTPUT
          fi
        env:
          CURRENT_OPENCODE_VERSION: ${{ steps.get-current-version.outputs.opencode }}
          LATEST_OPENCODE_VERSION: ${{ steps.get-latest-version.outputs.opencode }}

      - name: Update Dockerfile
        if: steps.compare-update.outputs.needs_update == 'true'
        run: |
          sed -i "s|^ARG OPENCODE_VERSION=.*|ARG OPENCODE_VERSION=$LATEST_OPENCODE_VERSION|" opencode/Dockerfile
        env:
          LATEST_OPENCODE_VERSION: ${{ steps.get-latest-version.outputs.opencode }}

      - name: Commit and push
        if: steps.compare-update.outputs.needs_update == 'true'
        run: |
          git config user.name 'github-actions[bot]'
          git config user.email 'github-actions[bot]@users.noreply.github.com'
          git add opencode/Dockerfile
          git commit -m "Update OpenCode to $OPENCODE_VERSION"
          git push
        env:
          OPENCODE_VERSION: ${{ steps.get-latest-version.outputs.opencode }}
```

**Step 3: Verify workflow**

Run: `cat opencode/.github/workflows/update.yaml | head -30`
Expected: Update workflow with correct paths to opencode/Dockerfile

**Step 4: Commit**

```bash
git add opencode/.github/workflows/update.yaml
git commit -m "add opencode update workflow"
```

---

### Task 9: Backup old build.yaml

**Files:**
- Modify: `.github/workflows/build.yaml`

**Step 1: Keep old workflow for reference**

Run:
```bash
mv .github/workflows/build.yaml .github/workflows/build.yaml.old
```

**Step 2: Verify move**

Run: `ls -la .github/workflows/`
Expected: build.yaml.old exists, build.yaml does not exist

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: backup old build.yaml to build.yaml.old"
```

---

### Task 10: Verify monorepo structure

**Files:**
- Verify: all files and directories

**Step 1: List top-level structure**

Run:
```bash
tree -L 2 -a -I '.git'
```

Expected output should include:
- `.github/workflows/` with:
  - `docker-build.yaml`
  - `build-closedagent.yaml`
  - `build-opencode.yaml`
  - `build.yaml.old`
- `opencode/` with:
  - `Dockerfile`
  - `compose.yaml`
  - `README.md`
  - `.github/workflows/update.yaml`

**Step 2: Verify opencode structure**

Run:
```bash
tree opencode
```

Expected: All opencode files present

**Step 3: Run YAML syntax check**

Run:
```bash
find .github/workflows -name '*.yaml' -exec echo "Checking {}" \; -exec yamllint {} \; 2>/dev/null || find .github/workflows -name '*.yaml' | xargs -I {} sh -c 'echo "Checking {}" && python3 -c "import yaml; yaml.safe_load(open(\"{}\"))"'
```

Expected: All YAML files are valid

**Step 4: Create verification summary**

Create a verification script:
```bash
cat > verify-monorepo.sh << 'EOF'
#!/bin/bash
echo "=== Verifying monorepo structure ==="
echo ""
echo " workflows:"
ls -1 .github/workflows/*.yaml
echo ""
echo " opencode files:"
ls -1 opencode/
echo ""
echo " opencode workflows:"
ls -1 opencode/.github/workflows/
echo ""
echo "=== Structure verified ==="
EOF
chmod +x verify-monorepo.sh
./verify-monorepo.sh
```

**Step 5: Commit**

```bash
git add verify-monorepo.sh
git commit -m "chore: add verification script"
```

---

### Task 11: Update top-level README

**Files:**
- Modify: `README.md` (if exists)

**Step 1: Check if README exists**

Run:
```bash
ls -la README.md
```

**Step 2: Add monorepo description**

If README exists, add this section:
```markdown
## Monorepo

This repository contains:

- **closedagent**: Base Docker image with development tools
- **opencode**: OpenCode AI sandboxed Docker image (extends closedagent)

Both images are built using reusable GitHub Actions workflows.

See individual directories for more information.
```

**Step 3: Commit if changed**

```bash
git add README.md
git commit -m "docs: add monorepo description to README"
```

---

### Task 12: Verify build triggers

**Files:**
- No files created - verification task

**Step 1: Review trigger paths in workflows**

Check build-closedagent.yaml triggers:
```bash
grep -A 10 "on:" .github/workflows/build-closedagent.yaml
```

Expected: Triggers on Dockerfile, entrypoint.d, scripts

**Step 2: Check build-opencode.yaml triggers**

Run:
```bash
grep -A 10 "on:" .github/workflows/build-opencode.yaml
```

Expected: Triggers on opencode/** paths

**Step 3: Verify reusable workflow is used by both**

Run:
```bash
grep -l "uses: ./.github/workflows/docker-build.yaml" .github/workflows/*.yaml
```

Expected: Both build-closedagent.yaml and build-opencode.yaml listed

**Step 4: Test workflow syntax with act (optional)**

If you have act installed:
```bash
act -l -W .github/workflows/
```

Expected: No syntax errors

---

### Task 13: Clean up verification script

**Files:**
- Modify: `verify-monorepo.sh`

**Step 1: Remove verification script**

Run (optional):
```bash
rm verify-monorepo.sh
```

**Step 2: Final verification**

Run:
```bash
git status
```

Expected: Only expected files pending (如果想remove verification script, add it)

**Step 3: Final commit (if removed)**

```bash
git add verify-monorepo.sh
git commit -m "chore: remove temporary verification script"
```

---

## Completion Checklist

- [ ] opencode/ directory created with all files
- [ ] Reusable docker-build.yaml workflow created
- [ ] build-closedagent.yaml workflow created and calls reusable
- [ ] build-opencode.yaml workflow created and calls reusable
- [ ] opencode/.github/workflows/update.yaml created
- [ ] Old build.yaml backed up as build.yaml.old
- [ ] All YAML workflows have valid syntax
- [ ] Trigger paths verified for both workflows
- [ ] File structure matches design document
- [ ] README updated with monorepo information
