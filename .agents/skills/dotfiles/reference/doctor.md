# Diagnose Dotfiles and Chezmoi Problems

Find the cause of a reported setup, init, template, diff, apply, or script problem. Default to read-only diagnostics: do not edit files, initialize/update the source, apply changes, alter chezmoi state, commit, push, or open a PR unless the user separately requests it.

1. Capture the exact command, error, expected result, and operating system. Read `AGENTS.md`, `.chezmoiroot`, Git status, and relevant files.
2. Verify chezmoi version and source path, executable availability, and whether the issue is in source parsing, template rendering, destination state, or a setup script. `.chezmoiroot` points to `home/`.
3. Prefer read-only checks such as `chezmoi doctor`, `status`, `diff`, and rendering a specific target with `chezmoi cat`. Use `make check` when relevant. Do not run state-changing commands as diagnostics.
4. Trace template errors through `home/.chezmoidata.yaml`, local `~/.config/chezmoi/chezmoi.toml`, and `home/.chezmoitemplates/`; inspect platform conditions, attributes, and target paths.
5. Treat local config and rendered files as sensitive. Do not print, copy, or include secret values or tokens. Redact values in diagnostic output.
6. Explain the confirmed cause, evidence, and minimal fix. Separate verified causes from hypotheses. If evidence is insufficient, request the specific safe diagnostic detail needed.
7. Do not apply a proposed fix automatically. If the user asks to fix it, follow the relevant workflow and review `chezmoi diff` before applying.

Never delete generated home files or reset chezmoi state as a troubleshooting shortcut.
