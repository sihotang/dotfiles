---
name: dotfiles-doctor
description: Use when the user reports a chezmoi setup, init, template, diff, or apply problem and wants help diagnosing it. Inspect state and recommend a safe fix without changing files or applying changes unless asked.
---

# Diagnose Dotfiles Problems

Find the cause of the reported chezmoi problem and give the user a specific, safe next step. Default to read-only diagnostics: do not edit files, initialize or update the source, run apply, alter chezmoi state, or commit, push, or open a PR unless the user separately requests it.

## Diagnostic workflow

1. Capture the exact command, error output, expected result, and relevant operating system. Read `AGENTS.md`, `.chezmoiroot`, Git status, and the files involved. Preserve existing user changes.
2. Verify the active chezmoi version, source directory, configured source state, executable availability, and whether the failure is in source parsing, template rendering, destination state, or a setup script. In this repository, `.chezmoiroot` points to `home/`.
3. Prefer read-only checks such as `chezmoi doctor`, `chezmoi status`, `chezmoi diff`, and rendering a specific target with `chezmoi cat`. Use this repository's `make check` when it covers the failing area. Do not run commands that update source or destination state as diagnostics.
4. Trace template failures through `home/.chezmoidata.yaml`, local `~/.config/chezmoi/chezmoi.toml`, and `home/.chezmoitemplates/`. Check platform conditions, filename attributes, and target paths before proposing a fix.
5. Treat local chezmoi configuration and rendered files as potentially sensitive. Do not print, copy, or include secret values or tokens in output. If a diagnostic command could reveal them, inspect only the needed key or redact values before reporting.
6. Explain the confirmed cause, supporting evidence, and a minimal fix. Separate verified causes from likely causes. If evidence is insufficient, state what safe, specific diagnostic detail is still needed.
7. Do not apply a proposed fix automatically. Make changes or apply them only when the user explicitly requests that next action; then follow the applicable repository workflow and review `chezmoi diff` before applying.

## Repository notes

- Keep machine-specific values in local `~/.config/chezmoi/chezmoi.toml`, not in the repository.
- The repo check is `make check`; it renders selected templates, checks shell syntax and managed JSON, checks whitespace, and displays `chezmoi diff`.
- Never delete generated home files or reset chezmoi state as a troubleshooting shortcut. Establish the cause and explain any state-changing recovery step before performing it.
