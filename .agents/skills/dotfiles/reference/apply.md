# Test and Apply Dotfiles Changes

Use this workflow when the user requests validation and application without committing or publishing.

1. Read the nearest `AGENTS.md`, `.chezmoiroot`, relevant source files, and Git status. Preserve unrelated user edits.
2. Run `make check`; fix failures and rerun it. Review the output, `git diff --check`, and `chezmoi --source "$PWD" diff`.
3. Ensure the rendered diff contains only intended targets. If unrelated targets appear, isolate the requested target paths or resolve the ambiguity before applying.
4. Apply reviewed changes with `chezmoi --source "$PWD" apply`, using target-specific arguments when needed. If there are no managed home targets, treat apply as a no-op.
5. Verify with `chezmoi --source "$PWD" status` and `chezmoi --source "$PWD" diff`; report whether intended targets are in sync.

Do not commit, push, or open a PR in this workflow. Keep host-specific values in local chezmoi configuration. Do not remove generated files from the home directory unless the user requests cleanup and obsolescence is confirmed.
