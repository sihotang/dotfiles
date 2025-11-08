# 🧩 Language Containers

Each language container extends the base DevContainer with language-specific tooling.

## Node

- **Path**: `devcontainers/node`
- **Includes**: Node.js (via apt, latest LTS), npm, zsh, git, chezmoi
- **Best for**: JavaScript/TypeScript projects, Node.js applications, frontend development

Example build:

```bash
docker build devcontainers/node -t ghcr.io/sihotang/devcontainer-node:latest
```

**Note**: For specific Node.js versions, modify the Dockerfile to use `nvm` or `fnm`.

## Python

- **Path**: `devcontainers/python`
- **Includes**: Python 3 (via apt), pip, zsh, git, chezmoi
- **Best for**: Python applications, data science, scripting

Example build:

```bash
docker build devcontainers/python -t ghcr.io/sihotang/devcontainer-python:latest
```

**Note**: For specific Python versions, consider using `pyenv` or official
Python images.

## Go

- **Path**: `devcontainers/go`
- **Includes**: Go toolchain (latest via apt), zsh, git, chezmoi
- **Best for**: Go applications, CLI tools, microservices

Example build:

```bash
docker build devcontainers/go -t ghcr.io/sihotang/devcontainer-go:latest
```

**Note**: For specific Go versions, modify the Dockerfile to install from
golang.org or use official Go images.

## .NET

- **Path**: `devcontainers/dotnet`
- **Includes**: .NET SDK 8.0 (via Microsoft package repository), zsh, git, chezmoi
- **Best for**: C# applications, ASP.NET Core, .NET development

Example build:

```bash
docker build devcontainers/dotnet -t ghcr.io/sihotang/devcontainer-dotnet:latest
```

**Note**: For specific .NET versions, modify the `DOTNET_VERSION` build arg in
the Dockerfile.
