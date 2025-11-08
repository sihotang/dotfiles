# Extend from base container
# Build base first: docker build -t sihotang/devcontainer-base:latest ../base
ARG BASE_IMAGE=sihotang/devcontainer-base:latest
FROM ${BASE_IMAGE}

# Install .NET SDK
USER root
RUN apt update && apt install -y wget apt-transport-https \
  && rm -rf /var/lib/apt/lists/*

# Add Microsoft package repository and install .NET SDK
ARG DOTNET_VERSION=8.0
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb \
  && apt update \
  && apt install -y dotnet-sdk-${DOTNET_VERSION} \
  && rm -rf /var/lib/apt/lists/*

# Verify .NET installation
RUN dotnet --version

