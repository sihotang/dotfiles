# 🧰 Troubleshooting

## Common Issues

- **DevContainer build failed**: Rebuild container (VS Code → Command Palette → Dev Containers: Rebuild).
- **chezmoi not found**: Install manually:

  ```bash
  sh -c "$(curl -fsLS get.chezmoi.io)"
  ```

- **SSH problems**: Ensure `.ssh` is mounted in `devcontainer.json`.
- **Wrong shell in VS Code**: set `"terminal.integrated.shell.linux": "/bin/zsh"`.

If problems persist, check logs and retry the `postCreateCommand`.
