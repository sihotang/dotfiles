# Extend from base container
# Build base first: docker build -t sihotang/devcontainer-base:latest ../base
ARG BASE_IMAGE=sihotang/devcontainer-base:latest
FROM ${BASE_IMAGE}

# Install Node.js-specific dependencies
USER root
RUN apt update && apt install -y ca-certificates gnupg \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS version via NodeSource)
ARG NODE_VERSION=20
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*
