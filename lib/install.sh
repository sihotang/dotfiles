install_chezmoi() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)"
  fi
}
