FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt update && apt install -y curl git zsh sudo jq vim \
  && rm -rf /var/lib/apt/lists/*

# Install chezmoi (standard installation method)
# Use full URL to avoid redirect issues in CI environments
RUN curl -fsLS https://get.chezmoi.io | sh || \
    (curl -fsLS https://www.chezmoi.io/get | bash) || \
    (echo "Failed to install chezmoi" && exit 1)

# Move chezmoi to /usr/local/bin for system-wide access
RUN mkdir -p /usr/local/bin && \
    if [ -f ~/bin/chezmoi ]; then \
        cp ~/bin/chezmoi /usr/local/bin/chezmoi; \
    elif [ -f /root/bin/chezmoi ]; then \
        cp /root/bin/chezmoi /usr/local/bin/chezmoi; \
    else \
        echo "Chezmoi binary not found after installation" && exit 1; \
    fi && \
    chmod +x /usr/local/bin/chezmoi

# Verify chezmoi is installed and accessible
RUN /usr/local/bin/chezmoi --version

# Set zsh as default shell
RUN chsh -s /bin/zsh vscode

# Switch to vscode user
USER vscode
