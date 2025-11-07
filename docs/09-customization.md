# 🎨 Customization Guide

Learn how to customize and extend your dotfiles setup.

## Adding New Dotfiles

### Using Chezmoi

1. **Add an existing file**:
   ```bash
   chezmoi add ~/.yourfile
   ```

2. **Create a new dotfile**:
   ```bash
   chezmoi add ~/.newfile
   # Edit the source file
   chezmoi edit ~/.newfile
   ```

3. **Apply changes**:
   ```bash
   chezmoi apply
   ```

### File Naming Convention

- Regular files: `dot_filename` (e.g., `dot_zshrc` → `~/.zshrc`)
- Hidden directories: `dot_dirname/` (e.g., `dot_config/` → `~/.config/`)
- Templates: `dot_filename.tmpl` (e.g., `dot_gitconfig.tmpl` → `~/.gitconfig`)

## Using Templates

Templates allow you to customize files per machine without committing sensitive data.

### Creating a Template

1. Add a file as template:
   ```bash
   chezmoi add --template ~/.gitconfig
   ```

2. Edit the template (use `{{ }}` syntax):
   ```ini
   [user]
     name = {{ .git.name }}
     email = {{ .git.email }}
   ```

3. Set template data:
   ```bash
   chezmoi data set git.name "Your Name"
   chezmoi data set git.email "your@email.com"
   ```

### Available Template Variables

You can use any data set via `chezmoi data set`. Common patterns:

- `.git.name` — Git user name
- `.git.email` — Git email
- `.os` — Operating system (detected automatically)
- `.hostname` — Machine hostname

### Adding Custom Variables

```bash
# Set custom variable
chezmoi data set myapp.api_key "secret123"

# Use in template
API_KEY={{ .myapp.api_key }}
```

## Modifying Existing Dotfiles

1. **Edit the source file**:
   ```bash
   chezmoi edit ~/.zshrc
   ```

2. **Or edit directly in the source directory**:
   ```bash
   cd ~/.local/share/chezmoi
   # Edit files directly
   ```

3. **Apply changes**:
   ```bash
   chezmoi apply
   ```

## Creating Custom Scripts

### Adding to `bin/`

1. Create your script:
   ```bash
   touch bin/my-script.sh
   chmod +x bin/my-script.sh
   ```

2. Make it available via chezmoi:
   ```bash
   chezmoi add bin/my-script.sh
   ```

3. Optionally, add to PATH in your shell config:
   ```bash
   # In ~/.zshrc
   export PATH="$HOME/bin:$PATH"
   ```

### Using Library Functions

Your scripts can use the library functions from `lib/`:

```bash
#!/usr/bin/env bash
set -e

# Source libraries
for file in "$(dirname "$0")"/../lib/*.sh; do 
  [ -f "$file" ] && source "$file"
done

# Use functions
log_info "Running my script..."
if [ "$(detect_os)" = "macos" ]; then
  # macOS specific code
fi
```

## Customizing DevContainers

### Adding Packages to Base Container

Edit `devcontainers/base/Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu
RUN apt update && apt install -y \
  curl git zsh sudo jq vim \
  your-package-here \
  && rm -rf /var/lib/apt/lists/*
```

### Creating a New Language Container

1. Create a new directory:
   ```bash
   mkdir devcontainers/rust
   ```

2. Create `Dockerfile`:
   ```dockerfile
   FROM mcr.microsoft.com/devcontainers/base:ubuntu
   RUN apt update && apt install -y \
     curl git zsh sudo jq vim \
     rustc cargo \
     && rm -rf /var/lib/apt/lists/*
   USER vscode
   RUN sh -c "$(curl -fsLS get.chezmoi.io)"
   RUN chezmoi init --apply sihotang
   ```

3. Create `devcontainer.json`:
   ```json
   {
     "name": "Rust DevContainer (sihotang)",
     "build": {
       "dockerfile": "Dockerfile"
     },
     "remoteUser": "vscode",
     "settings": {
       "terminal.integrated.defaultProfile.linux": "zsh"
     },
     "postCreateCommand": "chezmoi apply"
   }
   ```

## Organizing Your Dotfiles

### Recommended Structure

```
~/.local/share/chezmoi/
├── dot_zshrc              # Shell config
├── dot_gitconfig.tmpl     # Git config (template)
├── dot_gitignore_global   # Global gitignore
├── dot_bash_profile       # Bash profile
├── bin/                   # Scripts
│   ├── git-setup.sh
│   └── sync-dotfiles.sh
└── lib/                   # Library functions
    ├── git.sh
    ├── install.sh
    ├── log.sh
    └── os.sh
```

### Excluding Files

Create `.chezmoiignore` in your source directory:

```
*.swp
*.bak
.DS_Store
```

## Syncing Changes

### Workflow

1. **Make changes locally**:
   ```bash
   chezmoi edit ~/.zshrc
   ```

2. **Test the changes**:
   ```bash
   chezmoi apply
   ```

3. **Commit and push**:
   ```bash
   cd ~/.local/share/chezmoi
   git add .
   git commit -m "Update zshrc configuration"
   git push
   ```

Or use the sync script:
```bash
./bin/sync-dotfiles.sh
```

## Machine-Specific Customizations

### Using Different Configs Per Machine

1. **Use templates with hostname detection**:
   ```bash
   # In template file
   {{ if eq .hostname "work-laptop" }}
   # Work-specific config
   {{ else }}
   # Personal config
   {{ end }}
   ```

2. **Use different data per machine**:
   ```bash
   # On work machine
   chezmoi data set work.email "work@company.com"
   
   # On personal machine
   chezmoi data set work.email "personal@gmail.com"
   ```

3. **Use `.chezmoiignore`** for machine-specific files:
   ```
   dot_local_config
   ```

## Best Practices

1. **Always use templates** for files with sensitive data (API keys, emails, etc.)
2. **Test changes** with `chezmoi diff` before applying
3. **Keep dotfiles in git** for version control and backup
4. **Document customizations** in comments or this guide
5. **Use libraries** for reusable functionality
6. **Regular syncs** to keep all machines in sync

## Removing Dotfiles

### Remove a file from chezmoi management:

```bash
chezmoi remove ~/.oldfile
chezmoi apply
```

This removes the file from your home directory and from chezmoi source.

### Keep file but stop managing it:

```bash
chezmoi forget ~/.file
# File stays in home directory but is no longer managed
```

