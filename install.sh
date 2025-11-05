#!/usr/bin/env bash
for file in "$(dirname "$0")"/lib/*.sh; do [ -f "$file" ] && source "$file"; done
install_chezmoi
ensure_git
setup_gitignore
chezmoi init --apply sihotang
