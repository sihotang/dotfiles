---
name: chezmoi-sync
description: Use when the user invokes this skill or asks to test, apply, commit, and push chezmoi changes in this repository without creating a pull request. After checks pass and reviewed changes are applied, commit and push them.
---

# Sync Chezmoi Changes

Use this workflow when the user wants a requested chezmoi change validated, applied to their home directory, committed, and pushed. Invocation authorizes these steps but does not authorize opening or merging a pull request. Once checks pass and apply verification succeeds, continue through commit and push in the same run. If there are no managed home targets, treat apply as a no-op and continue after checks pass. Follow any more specific user instruction, including a request not to apply, commit, or push.

## Workflow

1. Read the nearest `AGENTS.md`, `.chezmoiroot`, relevant source files, Git status, current branch, and configured upstream. Preserve unrelated user changes.
2. Make only the requested source change under `home/`, preserving chezmoi filename attributes. Keep machine-specific values in local chezmoi configuration.
3. Run `make check`. Fix failures and rerun the check. Review its output, run `git diff --check`, and inspect `chezmoi diff` for unintended home-directory changes.
4. Apply only the reviewed requested targets with `chezmoi --source "$PWD" apply`. If unrelated source changes exist, pass target-specific paths. If no managed home targets changed, treat apply as a no-op. Verify the result with `chezmoi --source "$PWD" status` and `chezmoi --source "$PWD" diff`.
5. After successful checks and apply verification, stage only files for the requested change. Review the staged diff for unrelated files, secrets, credentials, private keys, or runtime state. Commit using the repository's conventions.
6. Push the commit to the current branch's configured upstream. Do not force push, change branches, or create or update a pull request. If there is no upstream, report that and push the current branch to the configured default remote only when the destination is unambiguous. If branch protection or another remote rule rejects the push, keep the commit and report the blocker.
7. Verify the commit, push result, and working tree state. Summarize the source changes, checks, apply result, commit, and push destination.

## Repository notes

- `.chezmoiroot` points to `home/`; repository tooling and this skill stay outside that source root.
- `make check` renders templates, checks Zsh syntax and managed JSON, checks whitespace, and prints `chezmoi diff`.
- Do not delete untracked or no-longer-managed files from the user's home directory unless the user asks for cleanup and the files are confirmed obsolete.
- Never include credentials, tokens, private keys, or local runtime state in a commit.
