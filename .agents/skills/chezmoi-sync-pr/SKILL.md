---
name: chezmoi-sync-pr
description: Use when the user invokes this skill or asks to create or update a PR for a chezmoi configuration change in this repository. After checks pass and reviewed changes are applied, commit, push, and create or update the PR.
---

# Sync Chezmoi Changes and Create a PR

Use this workflow for requested changes to this chezmoi repository. Invoking this skill authorizes applying the requested target changes to the user's home directory and publishing the source change in a pull request. Once checks pass and apply verification succeeds, continue through commit, push, and PR creation or update in the same run. If there are no managed home targets, treat apply as a no-op and continue after checks pass. Do not merge the pull request. Follow any more specific instruction from the user, including a request not to apply or publish.

## Workflow

1. **Read repository guidance.** Start at the repository root, read the nearest `AGENTS.md`, and inspect `.chezmoiroot`, the relevant source files, Git status, current branch, remote, and any open PR for the current branch. Preserve unrelated user changes.
2. **Plan the source edit.** Keep managed files under `home/`, preserve chezmoi filename attributes, and keep host-specific values in local chezmoi configuration. Make the smallest change that satisfies the request.
3. **Use an isolated branch.** If the requested work is not already on a suitable feature branch, update the local default branch with a fast-forward from its configured upstream, then create a branch following repository guidance. Keep unrelated working tree changes out of the branch and commit.
4. **Check the result.** Run `make check` after source changes. Fix failures and rerun it. Inspect its output, run `git diff --check`, and review `chezmoi diff` so the rendered home-directory changes are understood. Do not apply if checks fail or the rendered diff includes unrelated user changes; isolate the intended target paths or resolve the ambiguity first.
5. **Apply the requested targets.** Apply the reviewed changes with chezmoi. Use target-specific apply arguments when unrelated source changes exist. If filesystem access blocks the operation, request the required tool escalation and retry. Verify the result with `chezmoi status` and `chezmoi diff`; do not report success until both show the expected state.
6. **Commit and publish.** After successful checks and apply verification, stage only files for the requested change. Review the staged diff for accidental files, secrets, and unrelated edits. Commit with the repository's conventions, push the feature branch, and create a PR against the repository's default branch. If an open PR already exists for this branch, update that PR instead of creating a duplicate. Never merge it.
7. **Verify and report.** Confirm the PR URL/state and branch status. Summarize the source changes, checks run, application result, and PR link. If authentication, network access, or another external blocker prevents publication, complete all local work and report exactly what remains blocked.

## Repository-specific checks

- `.chezmoiroot` points to `home/`; repository tooling and this skill stay outside that source root.
- The repository requires `make check` after shell, template, or managed JSON changes. Run it for every change handled by this skill.
- `make check` validates Zsh syntax and managed JSON, checks whitespace, and prints `chezmoi diff`; inspect the rendered diff before applying.
- Do not add or run unrelated tests. Do not commit credentials, tokens, private keys, or local runtime state.
- Do not delete untracked or no-longer-managed files from the user's home directory unless the user asks for cleanup and the files are confirmed obsolete.
