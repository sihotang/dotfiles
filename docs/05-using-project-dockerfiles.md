# 🧩 Using DevContainers with Project Dockerfiles

There are three common approaches:

1. **Extend the project Dockerfile** — add a `.devcontainer/Dockerfile` that installs chezmoi and your tools.
2. **Mount chezmoi from host** — bind your local chezmoi folders into the container (fast, no rebuild).
3. **Multi-stage Dockerfile** — include a `dev` stage that installs build-time tools and chezmoi.

See examples in `devcontainers/README.md` and the main handbook.
