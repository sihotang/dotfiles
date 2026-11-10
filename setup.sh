#!/bin/sh

set -eu

platform=$(uname -s)
case "$platform" in
  MINGW*|MSYS*|CYGWIN*)
    printf '%s\n' 'Run setup.ps1 from PowerShell for native Windows.' >&2
    exit 1
    ;;
esac

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)

if ! command -v chezmoi >/dev/null 2>&1; then
  if [ "$platform" = Darwin ] && command -v brew >/dev/null 2>&1; then
    brew install chezmoi
  else
    if ! command -v curl >/dev/null 2>&1; then
      printf '%s\n' 'curl is required to install chezmoi. Install curl and run setup.sh again.' >&2
      exit 1
    fi

    install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"
    sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$install_dir"
    PATH="$install_dir:$PATH"
    export PATH
  fi
fi

if [ ! -f "$script_dir/.chezmoiroot" ]; then
  chezmoi init soparsio/dotfiles
  use_local_source=false
  source_dir=$(chezmoi source-path)
else
  use_local_source=true
  source_dir=$script_dir
fi

"$source_dir/scripts/copy-example-data.sh" "$source_dir"

printf '%s\n' 'Previewing dotfile changes:'
if [ "$use_local_source" = true ]; then
  chezmoi --source "$script_dir" diff
else
  chezmoi diff
fi

printf '%s' 'Apply these changes to your home directory? [y/N] '
IFS= read -r answer || answer=
case "$answer" in
  y|Y|yes|YES|Yes)
    if [ "$use_local_source" = true ]; then
      chezmoi --source "$script_dir" apply
    else
      chezmoi apply
    fi
    ;;
  *)
    printf '%s\n' 'No changes applied.'
    ;;
esac
