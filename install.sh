cat > install.sh <<'EOF'
#!/usr/bin/env bash
set -e
echo "Bootstrapping dotfiles (basic symlink installer)"
cd "$(dirname "$0")"
for f in .zshrc .gitconfig; do
  [ -f "$HOME/$f" ] && mv "$HOME/$f" "$HOME/$f.bak"
  ln -sf "$PWD/$f" "$HOME/$f"
done
echo "Done"
EOF
chmod +x install.sh