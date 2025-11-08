FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt update && apt install -y curl git zsh sudo jq vim \
  && rm -rf /var/lib/apt/lists/*

# Install chezmoi
USER vscode
RUN sh -c "$(curl -fsLS get.chezmoi.io)"

# Set zsh as default shell
USER root
RUN chsh -s /bin/zsh vscode
USER vscode
