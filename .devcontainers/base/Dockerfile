FROM mcr.microsoft.com/devcontainers/base:ubuntu
RUN apt update && apt install -y curl git zsh sudo jq vim 
USER vscode
RUN sh -c "$(curl -fsLS get.chezmoi.io)"
RUN chezmoi init --apply sihotang
