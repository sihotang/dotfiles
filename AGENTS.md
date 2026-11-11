# Dotfiles repository instructions

- `.chezmoiroot` sets `home/` as the chezmoi source root.
- Preserve chezmoi filename attributes such as `dot_`, `private_`, and `.tmpl`.
- Keep machine-specific values in the local `~/.config/chezmoi/chezmoi.yaml`; do not commit them.
- Reuse fragments from `home/.chezmoitemplates/` for shared template logic.
- Run `make check` after changing shell files, templates, or managed JSON settings.
- Review `chezmoi diff` before applying changes to the home directory.
- Keep comments in code and configuration in English.
- Do not include credentials, tokens, or runtime state from AI tools in this repository.
