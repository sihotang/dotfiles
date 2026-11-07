# Personal dotfiles

This repository manages personal shell, command-line, editor, and AI assistant
configuration with [chezmoi](https://www.chezmoi.io/). It uses zsh for its
bootstrap script and shell configuration.

## Getting started

Run the zsh setup script directly from GitHub:

```zsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/soparsio/dotfiles/main/setup.sh)"
```

The script installs chezmoi with Homebrew if needed, initializes this
repository, previews the changes, and asks before applying them. It requires
zsh, curl, and Git; it does not install Homebrew.

If chezmoi is already installed and you prefer to manage the steps yourself,
initialize the repository directly:

```sh
chezmoi init soparsio/dotfiles
```

Then preview and apply:

```sh
chezmoi diff
chezmoi apply
```

To run the script from a local clone, change to its root directory and run
`./setup.sh`. It uses that checkout as the chezmoi source.

## How the source is organized

The `.chezmoiroot` file tells chezmoi that `home/` contains the managed source
files. Filename attributes such as `dot_`, `private_`, and `.tmpl` control how
files are named, protected, and rendered when installed. For example,
`home/dot_zshrc` becomes `~/.zshrc`.

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

Keep per-machine values in `~/.config/chezmoi/chezmoi.toml`, outside this
repository. The templates provide defaults, so this file is optional. For
example:

```toml
[data]
ollamaHost = "127.0.0.1:11434"
workspaceDir = "Workspace"
```

`ollamaHost` configures the Ollama host used by the environment exports.
`workspaceDir` sets the directory opened by the workspace alias, relative to
your home directory.

Machine-specific Git settings belong in `~/.gitconfig.local`. The managed
`~/.gitconfig` includes that file if it exists; keep it local and out of this
repository.

## Checks

Run the repository check after changing shell files, templates, or managed JSON
settings:

```sh
make check
```

The target performs these checks in order:

1. Renders `~/.aliases`, `~/.exports`, and `~/.gemini/settings.json` with
   `chezmoi cat` into a temporary directory.
2. Checks zsh syntax for `home/dot_zprofile`, `home/dot_zshrc`,
   `home/dot_functions`, and the rendered aliases and exports.
3. Parses the rendered Gemini settings as JSON with Python's standard library.
4. Runs `git diff --check` to catch whitespace errors in tracked changes.
5. Prints `chezmoi diff` so you can review how the source differs from the
   files in your home directory.

The command needs chezmoi, zsh, Python 3, and Git. It does not apply changes;
review the final chezmoi diff and use `chezmoi apply` when you are ready.

## Contents

- Zsh startup files, aliases, shell functions, and environment exports
- Git and GitHub CLI configuration, plus global ignore patterns
- Vim and npm configuration
- Personal instructions for Claude Code, Cline, Continue, Cursor, GitHub
  Copilot, Gemini, and Codex
