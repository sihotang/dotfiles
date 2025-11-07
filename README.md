# 🧠 Dotfiles Starter by Sihotang

A complete, modular, cross-platform setup for developers.

Includes **chezmoi**, **zsh**, and **DevContainers** for Node, Python, and Go.


## 🚀 Quick Start

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply sihotang
```


## 📦 What's Inside

| Folder | Description |
|--------|-------------|
| `/lib` | Reusable shell helpers (install, os, git, log) |
| `/bin` | Automation scripts |
| `/docs` | Complete developer handbook |
| `/devcontainers` | Multi-language development containers |


## 🐳 Using DevContainers

Open in VS Code → **Reopen in Container**

```bash
docker build devcontainers/node -t ghcr.io/sihotang/devcontainer-node:latest
```


## 📚 Documentation

See [docs/README.md](docs/README.md) for the full handbook.
