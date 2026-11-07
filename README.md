# Personal dotfiles

This repository manages personal shell, command-line, editor, and AI assistant
configuration with [chezmoi](https://www.chezmoi.io/). Its shell configuration
uses Zsh.

## Getting started

On macOS, Linux, or WSL, run the POSIX shell setup script directly from GitHub:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/sihotang/dotfiles/main/setup.sh)"
```

On native Windows, run the PowerShell setup script:

```powershell
powershell -NoProfile -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/sihotang/dotfiles/main/setup.ps1')"
```

Each script installs chezmoi to a user-local directory if needed, initializes
this repository, previews the changes, and asks before applying them. Git is
required. On macOS, the shell script uses Homebrew when available and otherwise
installs chezmoi to `~/.local/bin`; it also requires `curl` for the fallback.
The PowerShell script uses PowerShell's web request support. The managed shell
configuration is for Zsh; on Windows, use WSL if you want to use that shell
configuration.

If chezmoi is already installed and you prefer to manage the steps yourself,
initialize the repository directly:

```sh
chezmoi init sihotang/dotfiles
```

Then preview and apply:

```sh
chezmoi diff
chezmoi apply
```

To run the scripts from a local clone, change to its root directory and run
`./setup.sh` on macOS, Linux, or WSL. On Windows, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

The scripts use that checkout as the chezmoi source.

## How the source is organized

The `.chezmoiroot` file tells chezmoi that `home/` contains the managed source
files. Filename attributes such as `dot_`, `private_`, and `.tmpl` control how
files are named, protected, and rendered when installed. For example,
`home/dot_zshrc` becomes `~/.zshrc`, and files under
`home/dot_config/zsh/` become modular Zsh configuration under `~/.config/zsh/`.
The `.zshrc` entry point loads those modules directly.

## Platform compatibility

On macOS, Linux, and WSL, GitHub CLI settings go to `~/.config/gh/`. On native
Windows, they go to `%APPDATA%\GitHub CLI\config.yml`; Vim uses `_vimrc`
instead of `.vimrc`. Zsh files are managed on Windows as well, and `.zshrc`
loads Oh My Zsh when it is installed. Oh My Zsh requires Zsh; on Windows, WSL 2
is recommended, while Cygwin or MSYS2 are alternatives. Native Windows setup
does not install either. If using Cygwin or MSYS2, ensure Zsh and chezmoi use
the same home directory. WSL uses Linux paths and needs no separate Windows
path configuration.

## Everyday use

Run these commands from the repository root to preview or apply updates:

```sh
chezmoi --source "$PWD" diff
```

```sh
chezmoi --source "$PWD" apply
```

Review the diff before applying. You can also rerun `./setup.sh` to preview and
confirm an apply. Edit source files under `home/`; destination files in your
home directory are managed outputs.

## Machine-specific settings

Shared template defaults live in `home/.chezmoidata.yaml`. Override them with
per-machine values in `~/.config/chezmoi/chezmoi.toml`, outside this repository.
The `home/.chezmoi.toml.tmpl` seeds local `[data]` values for the detected
hostname and operating system. Add or override other values locally, for example:

```toml
[data]
ollamaHost = "127.0.0.1:11434"
workspaceDir = "Workspace"
```

`ollamaHost` configures the Ollama host used by the environment exports.
`workspaceDir` sets the directory opened by the workspace alias, relative to
your home directory. `editor` sets the default editor for Zsh and Git; it
defaults to `code --wait`.

Git settings live under `home/dot_config/git/` and are included by the managed
`~/.gitconfig`. Machine-specific Git settings belong in `~/.gitconfig.local`;
keep that file local and out of this repository.

## Checks

Run the repository check after changing shell files, templates, or managed JSON
settings:

```sh
make check
```

The target performs these checks in order:

1. Renders the Zsh aliases and exports modules and `~/.gemini/settings.json`
   with `chezmoi cat` into a temporary directory.
2. Checks zsh syntax for `home/dot_zprofile`, `home/dot_zshrc`,
   `home/dot_config/zsh/functions.zsh`, and the rendered aliases and exports.
3. Parses the rendered Gemini settings as JSON with Python's standard library.
4. Runs `git diff --check` to catch whitespace errors in tracked changes.
5. Prints `chezmoi diff` so you can review how the source differs from the
   files in your home directory.

The command needs chezmoi, zsh, Python 3, and Git. It does not apply changes;
review the final chezmoi diff and use `chezmoi apply` when you are ready.
GitHub Actions runs this check for pull requests targeting `main` and pushes to
`main`.

## Contents

- Zsh startup files, aliases, shell functions, and environment exports
- Git and GitHub CLI configuration, plus global ignore patterns
- Vim and npm configuration
- Personal instructions for Claude Code, Cline, Continue, Cursor, GitHub
  Copilot, Gemini, and Codex
