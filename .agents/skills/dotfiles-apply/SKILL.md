---
name: dotfiles-apply
description: Use when the user invokes this skill or asks to test and apply changes in this chezmoi repository without creating a pull request. For requested dotfile and configuration edits, run the repo check, review rendered changes, and apply them after successful checks.
---

# Test and Apply Dotfiles Changes

Use this workflow when the user wants requested source changes validated and applied to their home directory. This skill does not create commits, push branches, or open pull requests. Follow any more specific user instruction, including a request not to apply.

## Workflow

1. Read the nearest `AGENTS.md`, `.chezmoiroot`, relevant source files, and Git status. Preserve unrelated user edits.
2. Make only the requested source change, keeping managed files under `home/` and preserving chezmoi filename attributes.
3. Run `make check`. Fix failures and rerun the check before applying.
4. Review `chezmoi diff` and ensure it contains only the intended target changes. If it includes unrelated user changes, apply only the requested target paths or resolve the ambiguity before proceeding.
5. Apply the reviewed targets with `chezmoi --source "$PWD" apply`. Request the necessary filesystem access if the sandbox blocks chezmoi state or home writes.
6. Verify with `chezmoi --source "$PWD" status` and `chezmoi --source "$PWD" diff`. Report whether the intended targets are in sync. If the task changes only repository tooling and no managed home targets, treat apply as a no-op and report that clearly.
7. Summarize the changes, checks, and apply result. Leave Git branch, commit, push, and PR operations to the user unless separately requested.

## Repository notes

- `.chezmoiroot` points chezmoi at `home/`.
- The repository check is `make check`; it renders templates, checks Zsh syntax and managed JSON, checks whitespace, and prints `chezmoi diff`.
- Keep machine-specific values in local `~/.config/chezmoi/chezmoi.toml` and never include credentials or local runtime state in the repository.
- Do not remove generated files from the home directory unless the user explicitly asks for cleanup and the files are confirmed obsolete.
