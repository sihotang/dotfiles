# 🐳 DevContainers Overview

DevContainers provide containerized, reproducible dev environments.

## Base concept
- `devcontainers/base` contains the shared foundation (chezmoi, zsh, git)
- Language folders (`node`, `python`, `go`) extend the base

## Usage
- Open repository in VS Code and choose *Reopen in Container*
- Or build locally:
```bash
docker build devcontainers/base -t ghcr.io/sihotang/devcontainer-base:latest
```
