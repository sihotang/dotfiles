# Extend from base container
# Build base first: docker build -t sihotang/devcontainer-base:latest ../base
ARG BASE_IMAGE=sihotang/devcontainer-base:latest
FROM ${BASE_IMAGE}

# Install Go-specific dependencies
USER root
RUN apt update && apt install -y wget \
  && rm -rf /var/lib/apt/lists/*

# Install Go (latest stable version)
ARG GO_VERSION=1.22.0
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
  && rm go${GO_VERSION}.linux-amd64.tar.gz

# Set up Go environment
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/vscode/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Create Go workspace directory
USER vscode
RUN mkdir -p ${GOPATH}/bin ${GOPATH}/src ${GOPATH}/pkg
