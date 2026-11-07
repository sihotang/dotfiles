#!/usr/bin/env zsh

set -euo pipefail

script_dir=${0:A:h}
source_args=()

if ! command -v chezmoi >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install chezmoi
  else
    print -u2 -- 'chezmoi is required. Install it with Homebrew or from https://www.chezmoi.io/install/.'
    exit 1
  fi
fi

if [[ -f "$script_dir/.chezmoiroot" ]]; then
  source_args=(--source "$script_dir")
else
  chezmoi init soparsio/dotfiles
fi

print -- 'Previewing dotfile changes:'
chezmoi "${source_args[@]}" diff

print -n -- 'Apply these changes to your home directory? [y/N] '
read -r answer
if [[ "$answer" != [yY] && "$answer" != [yY][eE][sS] ]]; then
  print -- 'No changes applied.'
  exit 0
fi

chezmoi "${source_args[@]}" apply
