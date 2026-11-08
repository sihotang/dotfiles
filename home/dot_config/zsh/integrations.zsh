#!/usr/bin/env zsh

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :

# Tool integrations (guarded so shell startup remains usable)
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
