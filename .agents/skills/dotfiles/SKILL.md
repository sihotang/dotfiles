---
name: dotfiles
description: Use for changes, reviews, troubleshooting, validation, application, or publishing work in this dotfiles repository. Load the reference for the requested workflow and honor its apply, commit, push, and PR boundaries.
---

# Work on This Dotfiles Repository

Route the request to the matching workflow reference below. Read that reference and applicable `AGENTS.md` instructions before acting. Preserve unrelated working-tree changes and follow any narrower instruction in the user's request.

- Add or reorganize configuration: [reference/add-config.md](reference/add-config.md)
- Test and apply without committing or publishing: [reference/apply.md](reference/apply.md)
- Audit configuration read-only: [reference/audit.md](reference/audit.md)
- Diagnose a chezmoi issue read-only: [reference/doctor.md](reference/doctor.md)
- Test, apply, commit, and push without a PR: [reference/sync.md](reference/sync.md)
- Test, apply, commit, push, and create or update a PR: [reference/sync-pr.md](reference/sync-pr.md)

For focused review, use the matching canonical prompt: [platform compatibility](agents/dotfiles-platform-reviewer.md), [templates and data](agents/dotfiles-template-reviewer.md), or [check coverage](agents/dotfiles-check-reviewer.md). Provider adapters are available under `.codex/agents/`, `.claude/agents/`, `.github/agents/`, and `.gemini/agents/`; each adapter loads the corresponding canonical prompt.

Do not infer authorization to apply, commit, push, or publish from a request to edit or review files. The selected workflow and the user's explicit instructions determine which actions are authorized.
