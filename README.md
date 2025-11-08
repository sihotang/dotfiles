# 🧠 Dotfiles Starter by Sihotang

A complete, modular, cross-platform setup for developers.

Includes **chezmoi**, **zsh**, and **DevContainers** for Node, Python, Go,
and .NET.

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

## 🧩 Sync docs to GitHub Wiki

Sync the `docs/` folder into the repository Wiki pages:

```bash
bin/sync-wiki.sh
```

Notes:

- Maps `docs/README.md` to `Home.md` on the Wiki.
- Requires `remote.origin.url` to be set to the GitHub repo.
