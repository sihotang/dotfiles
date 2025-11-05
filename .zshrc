cat > .zshrc <<'EOF'
# ~/.zshrc - example
export PROMPT="%F{blue}%n@%m%f:%F{green}%~%f$ "

alias ll="ls -lah"
alias gs="git status"
export PATH="$HOME/.local/bin:$PATH"
EOF