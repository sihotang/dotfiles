# DevContainers Overview

Includes Node, Python, Go, and Base images preconfigured with chezmoi.

## Structure

- `base/` - Base container with chezmoi, zsh, git, and common tools
- `go/` - Extends base, adds Go toolchain
- `node/` - Extends base, adds Node.js
- `python/` - Extends base, adds Python

## Building

Language containers extend from the base container. Build the base first:

```bash
# Build base container
docker build -t sihotang/devcontainer-base:latest devcontainers/base

# Build language containers (they will use the base)
docker build -t sihotang/devcontainer-go:latest devcontainers/go
docker build -t sihotang/devcontainer-node:latest devcontainers/node
docker build -t sihotang/devcontainer-python:latest devcontainers/python
```

Or use the build script:

```bash
# Build base only
./devcontainers/build.sh

# Build base and all language containers
./devcontainers/build.sh --all
```

## Using in VS Code

1. Open a project in VS Code
2. Copy a language devcontainer to `.devcontainer/`:

   ```bash
   cp -r devcontainers/go .devcontainer
   ```

3. Make sure base container is built first (see Building above)
4. Reopen in Container (VS Code command palette)

The language containers will automatically use the base container as their foundation.
