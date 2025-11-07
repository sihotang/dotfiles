# 🧰 Troubleshooting

## Common Issues

### DevContainer Build Failed

**Symptoms**: Container fails to build, errors during `postCreateCommand`.

**Solutions**:

1. Rebuild the container: VS Code → Command Palette → `Dev Containers: Rebuild Container`
2. Check Docker is running: `docker ps`
3. Verify Dockerfile syntax and base image availability
4. Check build logs: View → Output → Select "Dev Containers" from dropdown
5. Clear Docker cache: `docker system prune -a` (use with caution)

### Chezmoi Not Found

**Symptoms**: `chezmoi: command not found` in container or host.

**Solutions**:

- **In DevContainer**: Ensure the Dockerfile installs chezmoi:

  ```dockerfile
  RUN sh -c "$(curl -fsLS get.chezmoi.io)"
  ```

- **On host**: Install manually:

  ```bash
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply sihotang
  ```

### Wrong Shell in VS Code

**Symptoms**: Terminal opens with bash instead of zsh, or zsh not working.

**Solutions**:

1. Set in `devcontainer.json`:

   ```json
   {
     "settings": {
       "terminal.integrated.defaultProfile.linux": "zsh"
     }
   }
   ```

2. Ensure zsh is installed in the container
3. Rebuild the container after making changes

### SSH Problems in DevContainer

**Symptoms**: Cannot access private repositories, SSH keys not available.

**Solutions**:

1. Mount SSH directory in `devcontainer.json`:

   ```json
   {
     "mounts": [
       "source=${localEnv:HOME}/.ssh,target=/home/vscode/.ssh,type=bind,consistency=cached"
     ]
   }
   ```

2. Set correct permissions:

   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_rsa
   ```

3. Use SSH agent forwarding (if supported by your setup)

### Chezmoi Apply Fails

**Symptoms**: `chezmoi apply` command fails, templates not rendering.

**Solutions**:

1. Check template syntax in `dot_*.tmpl` files
2. Verify chezmoi data is set: `chezmoi data`
3. Set missing variables:

   ```bash
   chezmoi data set git.email "your@email.com"
   chezmoi data set git.name "Your Name"
   ```

4. Check for permission issues: `chezmoi diff` to see what would change

### Git Configuration Issues

**Symptoms**: Git commits show wrong user/email, or git not configured.

**Solutions**:

1. Set git config via chezmoi:

   ```bash
   chezmoi data set git.email "your@email.com"
   chezmoi data set git.name "Your Name"
   chezmoi apply
   ```

2. Or manually: `git config --global user.email "your@email.com"`
3. Verify: `git config --global --list`

### Permission Denied Errors

**Symptoms**: Scripts cannot execute, permission denied errors.

**Solutions**:

1. Make scripts executable:

   ```bash
   chmod +x bin/*.sh
   chmod +x install.sh
   ```

2. Check file ownership in containers
3. Ensure user has sudo access if needed (DevContainers usually run as `vscode` user)

### Dotfiles Not Syncing

**Symptoms**: Changes to dotfiles not reflected after `chezmoi apply`.

**Solutions**:

1. Check if files are managed by chezmoi: `chezmoi managed`
2. Add files to chezmoi: `chezmoi add ~/.yourfile`
3. Verify source state: `chezmoi source`
4. Force apply: `chezmoi apply --force` (use with caution)

## Getting Help

If problems persist:

1. Check logs: `chezmoi -v apply` for verbose output
2. Review DevContainer logs in VS Code Output panel
3. Verify all prerequisites are installed
4. Check the [chezmoi documentation](https://www.chezmoi.io/docs/)
5. Review DevContainer [troubleshooting guide](https://code.visualstudio.com/docs/devcontainers/troubleshooting)
