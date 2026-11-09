# Test, Apply, Commit, and Push Without a PR

Use this workflow when the user explicitly requests the full sync workflow or invokes it. It authorizes applying, committing, and pushing the requested change; it does not authorize creating or merging a PR. Honor any narrower instruction.

1. Read `AGENTS.md`, `.chezmoiroot`, relevant files, Git status, current branch, and upstream. Preserve unrelated changes.
2. Implement only the requested change under `home/`, preserving chezmoi attributes and keeping machine-specific values in local config.
3. Run `make check`, fix and rerun failures, run `git diff --check`, inspect check output, and review `chezmoi diff` for unrelated changes.
4. Apply reviewed targets using `chezmoi --source "$PWD" apply`; use target-specific paths if needed. If no managed home targets changed, treat apply as a no-op. Verify `status` and `diff` show expected state.
5. Stage only requested files. Review the staged diff for unrelated files, credentials, secrets, private keys, and runtime state. Commit using repository conventions.
6. Push to the current branch's configured upstream. Never force-push, change branches, or create/update a PR. If no upstream exists, use the configured default remote only when the destination is unambiguous; otherwise report it. If a remote rule rejects the push, keep the commit and report the blocker.
7. Verify commit, push destination, and clean working tree. Report checks, apply result, commit, and push outcome.
