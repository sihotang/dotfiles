#!/usr/bin/env bash
# Build script for devcontainers
# Builds base container first, then language-specific containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_TAG="sihotang/devcontainer-base:latest"

echo "🔨 Building base devcontainer..."
docker build -t "${BASE_TAG}" "${SCRIPT_DIR}/base"

echo ""
echo "✅ Base container built successfully!"
echo ""
echo "You can now build language-specific containers:"
echo "  docker build -t sihotang/devcontainer-go:latest ${SCRIPT_DIR}/go"
echo "  docker build -t sihotang/devcontainer-node:latest ${SCRIPT_DIR}/node"
echo "  docker build -t sihotang/devcontainer-python:latest ${SCRIPT_DIR}/python"
echo ""
echo "Or build all language containers:"
echo "  $0 --all"

if [[ "$1" == "--all" ]]; then
    echo ""
    echo "🔨 Building all language containers..."
    
    echo "  Building Go container..."
    docker build -t sihotang/devcontainer-go:latest "${SCRIPT_DIR}/go"
    
    echo "  Building Node container..."
    docker build -t sihotang/devcontainer-node:latest "${SCRIPT_DIR}/node"
    
    echo "  Building Python container..."
    docker build -t sihotang/devcontainer-python:latest "${SCRIPT_DIR}/python"
    
    echo ""
    echo "✅ All containers built successfully!"
fi

