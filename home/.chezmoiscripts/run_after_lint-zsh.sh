#!/bin/sh

set -eu

if ! command -v zsh >/dev/null 2>&1; then
  printf '%s\n' 'zsh is unavailable; skipping the post-apply syntax check.' >&2
  exit 0
fi

for file in \
  "$HOME/.zprofile" \
  "$HOME/.zshrc" \
  "$HOME/.config/zsh/aliases.zsh" \
  "$HOME/.config/zsh/exports.zsh" \
  "$HOME/.config/zsh/functions.zsh" \
  "$HOME/.config/zsh/integrations.zsh"
do
  [ ! -f "$file" ] || zsh -n "$file"
done

printf '%s\n' 'Zsh syntax check passed.'
