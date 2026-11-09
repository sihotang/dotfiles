# Audit Dotfiles Configuration

Perform a read-only review. Do not edit, apply, commit, push, or open a PR unless the user separately requests those actions.

1. Read `AGENTS.md`, `.chezmoiroot`, relevant neighboring files, `Makefile`, and Git status. Respect the requested scope and preserve unrelated work.
2. Trace each managed file from `home/` through attributes and templates to its rendered target. Check shared defaults in `home/.chezmoidata.yaml`, machine-specific values in local `~/.config/chezmoi/chezmoi.toml`, and shared logic in `home/.chezmoitemplates/`.
3. Check platform-specific paths and behavior on macOS, Linux, WSL, and native Windows where the affected configuration claims support. Review OS conditions, destination names, shell assumptions, setup script side effects/reruns, settings structure, documentation, and whether `make check` covers relevant paths.
4. Run only relevant existing checks. Do not add tests or fix findings during an audit unless asked. Avoid exposing secret values; report risk by file and key/context only.
5. Report actionable findings first, ordered by severity, with file/line references, evidence, and impact. Separate confirmed defects from risks or recommendations. If no issues are found, state scope, checks, and unverified platform behavior.
