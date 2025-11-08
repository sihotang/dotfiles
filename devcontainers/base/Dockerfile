FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt update && apt install -y curl git zsh sudo jq vim bash \
  && rm -rf /var/lib/apt/lists/*

# Install chezmoi system-wide
# Use bash explicitly and install to /usr/local/bin for all users
RUN bash -c "$(curl -fsLS https://get.chezmoi.io)" -- -b /usr/local/bin

# Verify chezmoi is installed and accessible
RUN /usr/local/bin/chezmoi --version

# Set zsh as default shell for vscode user
USER root
RUN chsh -s /bin/zsh vscode

# Switch to vscode user
USER vscode
