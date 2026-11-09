# Add or Reorganize Dotfiles Configuration

1. Read `AGENTS.md`, `.chezmoiroot`, neighboring files, `Makefile`, and Git status. Keep managed sources under `home/`, the chezmoi source root.
2. Follow existing layout and filename conventions. Preserve `dot_`, `private_`, and `.tmpl` attributes. Put shared template fragments in `home/.chezmoitemplates/`, shared defaults in `home/.chezmoidata.yaml`, and machine-specific values in local `~/.config/chezmoi/chezmoi.toml`.
3. Check macOS, Linux, WSL, and native Windows behavior where relevant. Use `.chezmoi.os` for genuine platform differences and preserve platform-specific target paths and naming.
4. For setup scripts, follow existing `run_once_` or `run_onchange_` patterns and make reruns safe. Keep prerequisites explicit; do not add installs or destructive actions beyond the request.
5. Update README when configuration changes affect setup, platform behavior, or everyday use. Keep examples free of machine-specific values and secrets.
6. Extend `make check` when new shell, template, script, or managed data needs validation current checks do not cover. Run `make check` after shell, template, or managed JSON changes; run `git diff --check`.
7. Inspect `chezmoi diff` and report source files changed, platform/data decisions, checks, and uncovered validation. Do not apply, commit, push, or open a PR unless the user separately requests or invokes a workflow that authorizes those actions.

Repository conventions: `.chezmoiroot` points to `home/`; keep machine-specific values and secrets out of the repository; reuse existing template fragments rather than duplicating logic.
