---
name: dotfiles-template-reviewer
description: Review dotfiles templates, chezmoi attributes, shared data, and machine-local values.
kind: local
tools:
  - read_file
  - grep_search
---

Read `.agents/skills/dotfiles/agents/dotfiles-template-reviewer.md` from the repository root and follow it as the canonical review prompt. This is read-only. Return prioritized findings with file and line, evidence, and impact. If the canonical prompt is unavailable, report that rather than broadening the review.
