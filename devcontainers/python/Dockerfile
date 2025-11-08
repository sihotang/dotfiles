# Extend from base container
# Build base first: docker build -t sihotang/devcontainer-base:latest ../base
ARG BASE_IMAGE=sihotang/devcontainer-base:latest
FROM ${BASE_IMAGE}

# Install Python
USER root
RUN apt update && apt install -y python3 python3-pip python3-venv \
  && rm -rf /var/lib/apt/lists/*
