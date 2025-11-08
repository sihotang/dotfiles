# DevContainers Overview

Includes Node, Python, Go, .NET, and Base images preconfigured with chezmoi.

## Structure

- `base/` - Base container with chezmoi, zsh, git, and common tools
- `go/` - Extends base, adds Go toolchain
- `node/` - Extends base, adds Node.js
- `python/` - Extends base, adds Python
- `dotnet/` - Extends base, adds .NET SDK

## Published Images

All containers are automatically built and published to GitHub Container
Registry (GHCR):

- `ghcr.io/sihotang/devcontainer-base:latest` - Base container
- `ghcr.io/sihotang/devcontainer-go:latest` - Go container
- `ghcr.io/sihotang/devcontainer-node:latest` - Node.js container
- `ghcr.io/sihotang/devcontainer-python:latest` - Python container
- `ghcr.io/sihotang/devcontainer-dotnet:latest` - .NET container

Images are automatically published when changes are pushed to the
`devcontainers/` directory.

**View published images**: <https://github.com/sihotang?tab=packages>

## Using Published Images (Recommended)

### In VS Code DevContainers

1. Copy a language devcontainer to your project's `.devcontainer/` directory:

   ```bash
   cp -r devcontainers/go .devcontainer
   # or
   cp -r devcontainers/node .devcontainer
   # or
   cp -r devcontainers/python .devcontainer
   # or
   cp -r devcontainers/dotnet .devcontainer
   ```

2. The `devcontainer.json` is already configured to use the published image
   from GHCR
3. Open in VS Code and select "Reopen in Container"

The published images will be automatically pulled from GHCR - no local build required!

### Pulling Images Manually

```bash
# Login to GHCR (if pulling private images)
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull images
docker pull ghcr.io/sihotang/devcontainer-base:latest
docker pull ghcr.io/sihotang/devcontainer-go:latest
docker pull ghcr.io/sihotang/devcontainer-node:latest
docker pull ghcr.io/sihotang/devcontainer-python:latest
docker pull ghcr.io/sihotang/devcontainer-dotnet:latest
```

## Building Locally (Optional)

If you want to build containers locally or customize them:

### Using the Build Script

```bash
# Build base only
./devcontainers/build.sh

# Build base and all language containers
./devcontainers/build.sh --all
```

### Manual Build

Language containers extend from the base container. Build the base first:

```bash
# Build base container
docker build -t sihotang/devcontainer-base:latest devcontainers/base

# Build language containers (they will use the base)
docker build -t sihotang/devcontainer-go:latest devcontainers/go
docker build -t sihotang/devcontainer-node:latest devcontainers/node
docker build -t sihotang/devcontainer-python:latest devcontainers/python
docker build -t sihotang/devcontainer-dotnet:latest devcontainers/dotnet
```

If building locally, update `devcontainer.json` to use the build configuration
instead of the image:

```json
{
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".",
    "args": {
      "BASE_IMAGE": "sihotang/devcontainer-base:latest"
    }
  }
}
```

## CI/CD

Images are automatically built and published via GitHub Actions when:

- Changes are pushed to `devcontainers/**` files
- Manual workflow dispatch is triggered

See `.github/workflows/publish-devcontainers.yml` for details.
