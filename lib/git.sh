ensure_git() {
  if ! command -v git >/dev/null 2>&1; then
    echo "Installing Git..."
    if [ "$(detect_os)" = "macos" ]; then
      brew install git
    else
      sudo apt update && sudo apt install -y git
    fi
  fi
}

setup_gitignore() {
  git config --global core.excludesfile ~/.gitignore_global
}
