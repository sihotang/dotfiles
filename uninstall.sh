#!/usr/bin/env bash
set -e

# ----------------------------------------
# 🧹 Dotfiles Uninstaller for Sihotang
# ----------------------------------------
# Safely removes chezmoi-managed dotfiles and local repo.
# Run with:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/sihotang/dotfiles/main/uninstall.sh)"
# ----------------------------------------

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

log() { echo -e "${GREEN}[+]${RESET} $1"; }
warn() { echo -e "${YELLOW}[!]${RESET} $1"; }
error() { echo -e "${RED}[x]${RESET} $1"; }

CHEZMOI_DIR="${HOME}/.local/share/chezmoi"
CHEZMOI_BIN="$(command -v chezmoi || true)"

echo -e "${YELLOW}⚠️  WARNING:${RESET} This will remove chezmoi and your local dotfiles configuration for 'sihotang'."
read -p "Are you sure you want to continue? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  log "Cancelled. No changes made."
  exit 0
fi

if [ -n "$CHEZMOI_BIN" ]; then
  log "Removing chezmoi-managed files..."
  chezmoi unmanaged | xargs -I {} rm -f "{}" 2>/dev/null || true
else
  warn "chezmoi not found. Skipping file cleanup."
fi

if [ -d "$CHEZMOI_DIR" ]; then
  log "Deleting chezmoi directory: $CHEZMOI_DIR"
  rm -rf "$CHEZMOI_DIR"
fi

if [ -f "/usr/local/bin/chezmoi" ]; then
  log "Removing chezmoi binary from /usr/local/bin"
  sudo rm -f /usr/local/bin/chezmoi
elif [ -n "$CHEZMOI_BIN" ]; then
  log "Removing chezmoi binary from $(dirname "$CHEZMOI_BIN")"
  sudo rm -f "$CHEZMOI_BIN"
fi

log "Cleaning complete ✅"
warn "You may still have custom files left (e.g. ~/.zshrc, ~/.gitconfig). Review them manually if needed."
log "🎉 Uninstall finished!"
