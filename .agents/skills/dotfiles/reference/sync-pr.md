# Test, Apply, Commit, Push, and Create a PR

Use this workflow when the user explicitly requests a PR workflow or invokes it. It authorizes applying requested targets, committing, pushing a feature branch, and creating/updating a PR; it does not authorize merging. Honor any narrower instruction.

1. Read `AGENTS.md`, `.chezmoiroot`, relevant files, Git status, current branch, remote, repository contribution guidance, and open PRs for the current branch. Preserve unrelated changes.
2. If needed, fast-forward the local default branch and create a feature branch following repository rules. Keep unrelated changes out of the branch and commit.
3. Implement only the requested source change under `home/`, preserving chezmoi attributes and machine-specific local values.
4. Run `make check`, fix and rerun failures, inspect its output, run `git diff --check`, and review `chezmoi diff`. Do not apply if checks fail or unrelated home targets appear.
5. Apply the reviewed targets with `chezmoi --source "$PWD" apply`, using target-specific paths when needed. If no managed home targets changed, treat apply as a no-op. Verify with `status` and `diff`.
6. Stage only requested files; review for secrets and unrelated edits. Commit using repository conventions, push the feature branch, then create a PR against the default branch. Update an existing open PR for the branch rather than duplicating it. Never merge.
7. Verify PR URL/state and branch status. Report changes, checks, apply result, and PR link. If external publication is blocked, complete local work and report the blocker.

Do not add unrelated tests, commit credentials/tokens/private keys/runtime state, or delete generated home files unless cleanup was requested and obsolescence confirmed.
