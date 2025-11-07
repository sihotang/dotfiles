# 🧩 Using DevContainers with Project Dockerfiles

There are three common approaches for integrating your dotfiles setup with project-specific Dockerfiles:

## 1. Extend the Project Dockerfile

Create a `.devcontainer/Dockerfile` that extends your project's Dockerfile and adds chezmoi:

```dockerfile
FROM your-project-image:latest

# Install chezmoi and dependencies
USER root
RUN apt update && apt install -y curl git zsh sudo \
  && rm -rf /var/lib/apt/lists/*

# Switch to vscode user and install chezmoi
USER vscode
RUN sh -c "$(curl -fsLS get.chezmoi.io)"
RUN chezmoi init --apply sihotang

# Set default shell
USER root
RUN chsh -s /bin/zsh vscode
USER vscode
```

Then create `.devcontainer/devcontainer.json`:

```json
{
  "name": "Project with Dotfiles",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "remoteUser": "vscode",
  "settings": {
    "terminal.integrated.defaultProfile.linux": "zsh"
  },
  "postCreateCommand": "chezmoi apply"
}
```

## 2. Mount Chezmoi from Host

Bind mount your local chezmoi directory to avoid rebuilding (fastest for development):

```json
{
  "name": "Project with Mounted Dotfiles",
  "image": "your-project-image:latest",
  "mounts": [
    "source=${localEnv:HOME}/.local/share/chezmoi,target=/home/vscode/.local/share/chezmoi,type=bind,consistency=cached"
  ],
  "remoteUser": "vscode",
  "postCreateCommand": "sh -c '$(curl -fsLS get.chezmoi.io)' && chezmoi apply"
}
```

**Benefits**: No rebuild needed when dotfiles change, works with any base image.

## 3. Multi-stage Dockerfile

Include a `dev` stage in your project Dockerfile:

```dockerfile
# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
CMD ["node", "index.js"]

# Development stage with dotfiles
FROM node:18-alpine AS dev
RUN apk add --no-cache curl git zsh sudo bash

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)"

# Create vscode user (matching DevContainer convention)
RUN adduser -D -s /bin/zsh vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscode
WORKDIR /workspace
RUN chezmoi init --apply sihotang
```

Use in `.devcontainer/devcontainer.json`:

```json
{
  "name": "Multi-stage Dev",
  "build": {
    "dockerfile": "Dockerfile",
    "target": "dev"
  },
  "remoteUser": "vscode",
  "settings": {
    "terminal.integrated.defaultProfile.linux": "zsh"
  }
}
```

## Which Approach to Use?

- **Approach 1**: Best when you want to keep project Dockerfiles separate from dotfiles setup
- **Approach 2**: Best for quick iteration and when you frequently change dotfiles
- **Approach 3**: Best when you want a single Dockerfile for both dev and production
