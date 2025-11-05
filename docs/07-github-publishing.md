# 🚀 GitHub Publishing Guide

Publish this repo at: `github.com/sihotang/dotfiles`

## Initial push
```bash
unzip dotfiles.zip -d dotfiles
cd dotfiles
git init
git add .
git commit -m "Initial commit: dotfiles starter by sihotang"
git remote add origin git@github.com:sihotang/dotfiles.git
git branch -M main
git push -u origin main
```

## Optional: Publish DevContainer images
Build and push images to GitHub Container Registry (GHCR) if needed:
```bash
docker build .devcontainers/base -t ghcr.io/sihotang/devcontainer-base:latest
docker push ghcr.io/sihotang/devcontainer-base:latest
```
