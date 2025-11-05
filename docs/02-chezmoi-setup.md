# ⚙️ Chezmoi Setup

Chezmoi manages your dotfiles and templates.

## Install
```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply sihotang
```

## Templates
`dot_gitconfig.tmpl` uses variables so private data is not committed:
```ini
[user]
  name = {{ .git.name }}
  email = {{ .git.email }}
```

Set local data:
```bash
chezmoi data set git.email "you@example.com"
chezmoi data set git.name "Sihotang"
chezmoi apply
```
