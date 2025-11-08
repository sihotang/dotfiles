# 📚 Library Functions and Scripts

This repository includes reusable shell libraries and automation scripts.

## 📁 Library Functions (`lib/`)

The `lib/` folder contains modular shell functions that can be sourced in your scripts.

### `lib/install.sh`

Provides installation helpers:

- **`install_chezmoi()`** — Installs chezmoi if not already present

  ```bash
  source lib/install.sh
  install_chezmoi
  ```

### `lib/git.sh`

Git-related utilities:

- **`ensure_git()`** — Installs git if missing (detects macOS/Linux)
- **`setup_gitignore()`** — Configures global gitignore file

```bash
source lib/git.sh
ensure_git
setup_gitignore
```

### `lib/os.sh`

OS detection utilities:

- **`detect_os()`** — Returns "macos", "linux", or "unknown"

  ```bash
  source lib/os.sh
  OS=$(detect_os)
  echo "Detected OS: $OS"
  ```

### `lib/log.sh`

Colored logging functions:

- **`log_info "message"`** — Green info messages
- **`log_warn "message"`** — Yellow warning messages
- **`log_error "message"`** — Red error messages

```bash
source lib/log.sh
log_info "Installation complete"
log_warn "This will modify your system"
log_error "Failed to install package"
```

## 🔧 Automation Scripts (`bin/`)

### `bin/git-setup.sh`

Quick git configuration script. Sets up basic git user name and email.

**Usage:**

```bash
./bin/git-setup.sh
```

**Note**: You may want to customize this script or use chezmoi templates for
git config instead.

### `bin/sync-dotfiles.sh`

Synchronizes dotfiles from your home directory back to the chezmoi source,
commits, and pushes.

**Usage:**

```bash
./bin/sync-dotfiles.sh
```

**What it does:**

1. Adds new/modified files to chezmoi: `chezmoi add ~`
2. Applies changes: `chezmoi apply`
3. Commits to git: `git add . && git commit -m "Update dotfiles"`
4. Pushes to remote: `git push`

**Note**: Make sure you're in the dotfiles repository directory and have git
remote configured.

## Using Libraries in Your Scripts

Example script using the libraries:

```bash
#!/usr/bin/env bash
set -e

# Source all libraries
for file in "$(dirname "$0")"/lib/*.sh; do 
  [ -f "$file" ] && source "$file"
done

# Use the functions
log_info "Starting installation..."
install_chezmoi
ensure_git
setup_gitignore

if [ "$(detect_os)" = "macos" ]; then
  log_info "macOS detected, using Homebrew"
else
  log_info "Linux detected, using apt"
fi

log_info "Installation complete!"
```

This pattern is used in `install.sh` at the root of the repository.
