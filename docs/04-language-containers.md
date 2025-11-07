# 🧩 Language Containers

Each language container extends the base.


## Node

- Path: `devcontainers/node`
- Adds Node.js (LTS), npm, pnpm, yarn
- Example build:

```bash
docker build devcontainers/node -t ghcr.io/sihotang/devcontainer-node:latest
```


## Python

- Path: `devcontainers/python`
- Adds Python 3 and pip


## Go

- Path: `devcontainers/go`
- Adds Go toolchain
