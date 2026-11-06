# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

The `.chezmoiroot` file sets `home/` as the source directory. Files named
`dot_*` there are installed in the home directory with the leading `dot_`
converted to `.`.

## Apply changes

Preview pending changes:

```sh
chezmoi diff
```

Apply the source state to your home directory:

```sh
chezmoi apply
```

Edit files under `home/`, then run `chezmoi diff` and `chezmoi apply`.

Machine-specific values are read from the local chezmoi config, which is not
stored in this repository. For example, add these values to
`~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
ollamaHost = "127.0.0.1:11434"
workspaceDir = "Workspace"
```

The templates default to these values when a key is not set.

## Contents

- Zsh startup files, aliases, and environment exports
- Git configuration and global ignore patterns
- Vim and npm configuration

Machine-specific Git settings can go in `~/.gitconfig.local`; it is included
by the managed `~/.gitconfig` and is intentionally kept outside this repository.
