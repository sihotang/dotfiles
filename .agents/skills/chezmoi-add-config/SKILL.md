---
name: chezmoi-add-config
description: Use when adding or reorganizing a dotfile, application setting, or setup behavior in this chezmoi repository. Follow its source layout, template and data conventions, platform support, checks, and documentation.
---

# Add Configuration to This Chezmoi Repository

Use this workflow to add or reorganize managed configuration consistently with this repository. Implement the requested source change only; do not apply it to the home directory, commit it, push it, or open a PR unless the user separately requests those actions or invokes a workflow skill that authorizes them.

## Workflow

1. Read `AGENTS.md`, `.chezmoiroot`, the relevant neighboring files, `Makefile`, and the working tree state. Keep managed sources under `home/`, which is the chezmoi source root.
2. Follow existing layout and filename conventions. Preserve chezmoi attributes such as `dot_`, `private_`, and `.tmpl`. Put shared template fragments in `home/.chezmoitemplates/` and shared defaults in `home/.chezmoidata.yaml`; keep machine-specific values and secrets in local `~/.config/chezmoi/chezmoi.toml`.
3. Check how the config behaves on macOS, Linux, WSL, and native Windows where relevant. Use `.chezmoi.os` or other chezmoi platform data for genuine differences, and preserve existing platform-specific destinations and filename conventions.
4. For setup scripts, follow existing `run_once_` or `run_onchange_` patterns and make reruns safe. Keep package-manager and platform assumptions explicit. Do not add installs or destructive actions beyond the request.
5. Update README or other repo documentation when the new setting changes setup, configuration, platform behavior, or everyday use. Keep documentation and examples free of machine-specific values and secrets.
6. Extend `make check` when the new shell, template, script, or managed data needs validation that current checks do not cover. Run `make check` after shell, template, or managed JSON changes, and run `git diff --check`.
7. Inspect `chezmoi diff` to understand the rendered home target changes. Report the files changed, platform or data choices, checks performed, and any uncovered validation. Leave apply, commit, push, and PR actions to the user unless separately authorized.

## Repository conventions

- `.chezmoiroot` points to `home/`; repository tooling such as `Makefile`, `README.md`, and skills stays outside that source root.
- Use `.chezmoidata.yaml` for shared defaults and `~/.config/chezmoi/chezmoi.toml` for local overrides.
- Reuse `home/.chezmoitemplates/` for shared template logic rather than duplicating it.
- Never commit credentials, tokens, private keys, or local runtime state.
