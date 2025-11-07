# 🚀 GitHub Publishing Guide

Publish this repo at: `github.com/sihotang/dotfiles`

## Initial push

If you're starting from this repository:

```bash
git init
git add .
git commit -m "Initial commit: dotfiles starter by sihotang"
git remote add origin git@github.com:sihotang/dotfiles.git
git branch -M main
git push -u origin main
```

Or if cloning and customizing:

```bash
git clone git@github.com:sihotang/dotfiles.git
cd dotfiles
# Make your customizations
git remote set-url origin git@github.com:YOUR_USERNAME/dotfiles.git
git push -u origin main
```

## Optional: Publish DevContainer images

Build and push images to GitHub Container Registry (GHCR) if needed:

```bash
docker build devcontainers/base -t ghcr.io/sihotang/devcontainer-base:latest
docker push ghcr.io/sihotang/devcontainer-base:latest
```
