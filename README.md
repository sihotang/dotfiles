# Personal dotfiles

This repository manages personal shell, command-line, editor, and AI assistant
configuration with [chezmoi](https://www.chezmoi.io/). Its shell configuration
uses Zsh.

## Getting started

On macOS, Linux, or WSL, run the POSIX shell setup script directly from GitHub:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/soparsio/dotfiles/main/install.sh)"
```

On native Windows, run the PowerShell setup script:

```powershell
powershell -NoProfile -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/soparsio/dotfiles/main/install.ps1')"
```

Each script installs chezmoi to a user-local directory if needed, initializes
this repository, copies missing machine-local data files from
`examples/.chezmoidata/`, previews the changes, and asks before applying them.
Existing local data files are preserved. Git is required. On macOS, the shell
script uses Homebrew when available and otherwise installs chezmoi to
`~/.local/bin`; it also requires `curl` for the fallback. The PowerShell script
uses PowerShell's web request support. The managed shell configuration is for
Zsh; on Windows, use WSL if you want to use that shell configuration.

If chezmoi is already installed and you prefer to manage the steps yourself,
initialize the repository directly:

```sh
chezmoi init soparsio/dotfiles
```

Before previewing or applying, copy the missing machine-local data examples:

```sh
source_dir=$(chezmoi source-path)
sh "$source_dir/scripts/copy-example-data.sh" "$source_dir"
```

In PowerShell, run:

```powershell
$sourceDir = chezmoi source-path
& "$sourceDir/scripts/copy-example-data.ps1" -SourceDir $sourceDir
```

On macOS, `chezmoi apply` installs the Homebrew packages listed in
`.chezmoiscripts/darwin/run_onchange_before_install-packages.sh.tmpl` when
Homebrew is available. The package script runs again when its package list
changes. It installs `mise` with the optimized `mise.run` installer instead
of Homebrew, removing an existing Homebrew `mise` formula during the one-time
migration.

Then preview and apply:

```sh
chezmoi diff
chezmoi apply
```

To run the scripts from a local clone, change to its root directory and run
`./install.sh` on macOS, Linux, or WSL. On Windows, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

The scripts use that checkout as the chezmoi source.

## How the source is organized

The `.chezmoiroot` file tells chezmoi that `home/` contains the managed source
files. Filename attributes such as `dot_`, `private_`, and `.tmpl` control how
files are named, protected, and rendered when installed. For example,
`home/dot_zshrc` becomes `~/.zshrc`, and files under
`home/dot_config/zsh/` become modular Zsh configuration under `~/.config/zsh/`.
The `.zshrc` entry point loads those modules directly.

## Platform compatibility

On macOS, Linux, and WSL, GitHub CLI settings go to `~/.config/gh/`. On native
Windows, they go to `%APPDATA%\GitHub CLI\config.yml`; Vim uses `_vimrc`
instead of `.vimrc`. Zsh files are managed on Windows as well, and `.zshrc`
loads Oh My Zsh when it is installed. Oh My Zsh requires Zsh; on Windows, WSL 2
is recommended, while Cygwin or MSYS2 are alternatives. Native Windows setup
does not install either. If using Cygwin or MSYS2, ensure Zsh and chezmoi use
the same home directory. WSL uses Linux paths and needs no separate Windows
path configuration.

## Everyday use

Run these commands from the repository root to preview or apply updates:

```sh
chezmoi --source "$PWD" diff
```

```sh
chezmoi --source "$PWD" apply
```

Review the diff before applying. You can also rerun `./install.sh` to preview and
confirm an apply. Edit source files under `home/`; destination files in your
home directory are managed outputs.

## Machine-specific settings

Shared template defaults live in `home/.chezmoidata.yaml`. Override them with
per-machine values in `~/.config/chezmoi/chezmoi.yaml`, outside this repository.
The `home/.chezmoi.yaml.tmpl` seeds local `data` values for the detected
hostname and operating system. Add or override other values locally, for example:

```yaml
data:
  ollamaHost: 127.0.0.1:11434
  workspaceDir: Workspace
```

`ollamaHost` configures the Ollama host used by the environment exports.
`workspaceDir` sets the directory opened by the workspace alias, relative to
your home directory. `editor` sets the default editor for Zsh and Git; it
defaults to `code --wait`.

Global mise settings live in `~/.config/mise/config.toml`; Node.js `24.21.0` is
the configured default, with Bun, the latest stable Go, ripgrep, and Python
`3.15.2` also managed by mise. Mise updates itself automatically. Codex CLI,
Claude Code, Gemini CLI, and GitHub Copilot CLI are installed globally through npm,
managed as mise npm tools with Bun as the package manager. After applying the
config, chezmoi installs Bun first, then runs `mise install` for configured
tools. It runs again when the mise config changes. Starship's prompt settings
live in `~/.config/starship.toml`, and Atuin settings live in
`~/.config/atuin/config.toml`. The Zsh integration sets `ATUIN_CONFIG_DIR` to
that Atuin directory. The existing `~/.atuin/config.toml` is left untouched.
Ghostty is installed as a Homebrew cask on macOS, with its config at
`~/.config/ghostty/config`.
Google Chrome is installed as a Homebrew cask on macOS.
OrbStack is installed as a Homebrew cask on macOS.
Cursor is installed as a Homebrew cask on macOS.
Obsidian is installed as a Homebrew cask on macOS.
The package setup runs `brew cleanup --prune=all` afterward to remove old
package versions and stale cache files.
Neovim is installed as a Homebrew formula, and its configuration reuses the
shared Vim settings at `~/.config/nvim/init.vim`.
Visual Studio Code is installed as a Homebrew cask on macOS, with portable user
settings managed at `~/Library/Application Support/Code/User/settings.json`.
Machine-specific extension paths and temporary agent instruction paths are
kept out of the shared settings.

Git settings live under `home/dot_config/git/` and are included by the managed
`~/.gitconfig`. Machine-specific global Git settings belong in
`~/.gitconfig.local`; keep that file local and out of this repository.

## Profiles for CLI tools and app integrations

Configure profiles in the machine-local, Git-ignored
`home/.chezmoidata/profile.yaml` file. Create the `.chezmoidata` directory
under the source root (`home/` in this repo), then copy
`examples/.chezmoidata/profile.yaml.example` as a starting point. This file
contains both the top-level Git identity and the `profiles` mapping.

Shared AI-agent instructions are machine-local too. Copy
`examples/.chezmoidata/ai.yaml.example` to `home/.chezmoidata/ai.yaml` on each
machine, then customize `ai.instructions` for that machine. The local
`.chezmoidata` directory is ignored by Git. Provider templates supply a title
such as `Codex` or `Claude Code` to the shared renderer. Create the local file
before running `chezmoi apply` on a fresh machine so instructions are available
to templates.

Each profile is an object with optional `alias`, `name`, `email`,
`gh.username`, and a `tools` list. `gh.username` is the GitHub login selected by
`gh auth switch`; it defaults to the profile ID when omitted. Set it when the
GitHub login differs from the profile ID. `name` and
`email` are the profile-level Git identity
fallback. Profile IDs remain the stable names used by CLI directories and
configuration. `alias` sets the native Git and GitHub CLI account alias names;
if omitted, the profile ID is used. Run `git <alias> <command>` to use a
profile's Git identity, and `gh <alias> <command>` to use its GitHub CLI
account. Git alias names replace periods and underscores with hyphens, and
prefix `profile-` when the result starts with a number, to meet Git's alias
name rules.
`name` sets the profile's Git identity fallback and selects the matching native
VS Code profile. If omitted, the profile ID is used. The local `profile.yaml`
file is ignored by Git, so profile
definitions stay on that machine. Other machine-specific options such as
`defaultProfile` can remain in `~/.config/chezmoi/chezmoi.yaml`. Set
`defaultProfile` to a configured profile that enables `vscode` to make plain
`code` open that profile every time. Set it to `"Default"` to use VS Code's
built-in Default Profile. `profilesDir` defaults to `.config/profiles` when
omitted. For example, the machine-local config can contain:

```yaml
data:
  defaultProfile: work
```

Profiles can customize AI-agent instructions in the local `profile.yaml`:

- `profiles.instructions` replaces shared AI instructions for all profiles by
  default.
- `profiles.<id>.instructions` replaces the provider's shared instructions for
  all AI tools enabled by that profile, and overrides `profiles.instructions`.
- `profiles.<id>.<tool>.instructions` sets instructions for that tool. With
  `force: true`, it replaces shared and profile-level text. With `force: false`
  or an omitted `force`, it appends to inherited text.
- `profiles.<id>.ai.instructions` sets instructions for all AI tools enabled by
  that profile. With `force: true`, it replaces inherited profile instructions.
  With `force: false` or an omitted `force`, it appends to inherited text.
- `force` defaults to `false`; set it to `true` to replace inherited
  instructions. An empty `instructions` string is treated as unset.

For example, add `tools: [codex]` to each profile that should receive a
Codex instruction file:

```yaml
profiles:
  instructions: |
    For every profile, make small changes and explain validation.
  work:
    tools: [codex, claude, gemini]
    ai:
      force: true
      instructions: |
        For work projects, prefer small changes and do not change public APIs without confirmation.
    codex:
      force: false
      instructions: |
        For work sessions, summarize API compatibility risks before editing.
  personal:
    tools: [codex]
    ai:
      force: false
      instructions: |
        For personal projects, explore alternatives before choosing an implementation.
    codex:
      force: false
      instructions: |
        Keep personal-project explanations concise and include meaningful tradeoffs.
```

When a profile or tool instruction override is configured, the setup script writes
a generated instruction file into that profile's tool directory. Edit the
local `profile.yaml` value to change it. With no custom instructions, profile
directories continue to symlink the shared provider file. Existing custom
instruction files in profile directories are preserved and reported instead of
being overwritten.

Git identity follows `profiles.<id>.git.name/email`, then the profile-level
`name/email` field independently, then Git's global configuration. A `git`
mapping only affects profiles that include `git` in `tools`. For example:

```yaml
profiles:
  personal:
    name: Your Personal Name
    email: you@example.com
    tools: [git, gh]
    git:
      name: Your Git Name
      email: another@example.com
    gh:
      username: your-personal-github-username
```

Keep real names and email addresses in the ignored local `profile.yaml` file.
The native Git alias uses the configured identity and, when `gh` is also
enabled, switches to that profile's GitHub CLI account. The native GH alias
also supplies the profile's Git identity to Git subprocesses launched by that
GH command when the profile enables both tools. This Git identity is scoped to
the command and does not change global Git config. Profiles without an identity
override use the global identity from `~/.gitconfig`.

Then `code-sio-shared` opens the VS Code profile named `Sio Shared`.
`dotfiles` opens this chezmoi source directory in the built-in Default Profile,
and `dotfiles-sio-shared` opens it in the `Sio Shared` profile. A
`dotfiles-<profile>` launcher is generated for each configured profile that
enables `vscode`.

This creates directories such as `~/.config/profiles/work/codex/` and
`~/.config/profiles/personal/<tool>/` for tools with per-profile state. GH
accounts use the shared `~/.config/gh/` configuration. Run `chezmoi apply` to
create profile directories and seed shared instructions. A profile mapped to
an empty tool list is removed from `~/.config/profiles/` on apply. Profile
settings and state stay outside the repo.

Sign in to each CLI first; run `gh auth login` for each account before using
profile aliases to switch between them:

```sh
codex-work
codex-personal
gh auth login
# Repeat `gh auth login` for each account.
gh auth login
git work push
git personal push
git your-client-alias push
claude-personal
copilot-personal
gemini-personal
code-work .
code-personal .
profile-use gh personal auth status
profile-use codex personal --help
```

`profile-use TOOL PROFILE [arguments…]` is the general launcher for profiled
tools; other tools' shortcuts use `<tool>-<profile>`. `gh` aliases and
`profile-use gh PROFILE` use the shared `~/.config/gh/` configuration and first
switch to the username in `profiles.<id>.gh.username`. Sign in to each account
with plain `gh auth login` before using profile aliases. Gemini stores its
files in a `.gemini/` directory inside the profile's Gemini directory.

Each native `gh <alias>` command uses `gh auth switch` to select the configured
GitHub account. The alias removes `GH_CONFIG_DIR`, `GH_TOKEN`, `GITHUB_TOKEN`,
`GH_ENTERPRISE_TOKEN`, and `GITHUB_ENTERPRISE_TOKEN` from its child process so
environment overrides do not take precedence over the selected account.
When the profile also enables `git`, the alias passes its Git identity to Git
subprocesses launched by that GH command. If the profile enables only one
tool, the alias switches only that tool.
GitHub CLI may store credentials in the operating system credential manager.
See the [gh environment variable reference](https://cli.github.com/manual/gh_help_environment).

For Git over HTTPS, `git <alias> <command>` switches to that profile's GitHub
account and runs Git with the GitHub CLI credential helper without changing
global Git config. A VS Code profile with
`gh` enabled also configures the helper for plain `git` commands in its
integrated terminal. SSH remotes continue to use the SSH key selected by SSH,
so use an HTTPS remote when you want the GitHub CLI profile to choose the
account. Git 2.31 or newer is required for Git's environment-based config
overrides.

`code-<profile>` launches VS Code with the matching native VS Code profile and
environment paths for the CLI tools listed in that profile. VS Code keeps its
usual shared user data, so its primary sign-in is available across profiles;
profile-specific settings and extension selections remain managed by VS Code.
The profile setup script prepares CLI state directories but does not launch
VS Code. Start each profile with `code-<profile>` so VS Code starts with the
matching CLI environment. The VS Code `Default` profile uses Codex's default
home; other profiles with `codex` enabled use their matching `CODEX_HOME`. The
`--profile` CLI option creates a native profile if it does not exist, so newly
created profiles start empty. The managed user settings list its shared keys
in `workbench.settings.applyToAllProfiles`, so changes to those settings in
Default or another profile are applied across all profiles. Profile-specific
settings outside that list remain local. See the
[VS Code Profiles guide](https://code.visualstudio.com/docs/configure/profiles).
Chezmoi does not install or synchronize VS Code extensions. The integrated
terminal and CLI-backed extensions inherit environment paths for the selected
CLI profile.

Arguments passed to `code-<profile>` go directly to VS Code; the launcher does
not create profile-specific workspace files. Fully quit every VS Code window
before switching launchers: VS Code takes environment variables from its first
running instance, so another profile opened while it is still running can keep
the first profile's `CODEX_HOME`.

Add `antigravity` to a profile's agent list to enable Google's Antigravity
extension there; it is a VS Code extension toggle and does not create a CLI
launcher.

Codex profile settings live in
`~/.config/profiles/<profile>/codex/config.toml`. The setup links the shared
Codex `AGENTS.md`, Claude `CLAUDE.md`, Copilot instructions, and Gemini
instructions/settings when present. Codex profiles use file-based authentication
so each `CODEX_HOME` keeps its own `auth.json` and can sign in to a separate
account. VS Code uses its native profile store;
`code-<profile>` opens that profile and creates an empty one on first use if
the name does not exist yet.

GitHub Copilot, Claude Code, Codex, Gemini CLI, and Antigravity load their
project-level session-start hooks from `.github/hooks/hooks.json`,
`.claude/settings.json`, `.codex/hooks.json`, `.gemini/settings.json`, and
`.agents/hooks.json`, respectively. Each hook reminds the provider to follow
the repository's `dotfiles` skill workflow. These hook files are
provider-specific; review and trust them in each provider before enabling
them. Run `make check-assistant-configs` to validate their JSON syntax; this
check is separate from the chezmoi dotfiles checks and does not validate
provider-specific runtime behavior.

Copilot CLI reads its settings and local state from `COPILOT_HOME`, but its
OAuth credential may be held in the operating system keychain. Separate
`COPILOT_HOME` directories therefore isolate configuration and state; they may
not provide separate GitHub sign-ins on every platform. `GH_TOKEN`,
`GITHUB_TOKEN`, or `COPILOT_GITHUB_TOKEN` can also override its stored OAuth
login, so keep any such credentials outside this repository.

Claude Code also notes an authentication exception: separate config
directories isolate most logins, but Console sign-ins without an API key may
be stored outside that directory. Check the CLI's authentication behavior for
your sign-in method before relying on complete account isolation.

## Checks

Run the repository check after changing shell files, templates, or managed JSON
settings:

```sh
make check
```

The target renders the Zsh modules, profile setup script, Gemini settings, and
VS Code settings into a temporary directory. It checks profile template
behavior, Zsh and POSIX shell syntax, JSON validity, and tracked whitespace.

The command needs chezmoi, zsh, Python 3, and Git. It does not apply changes;
review `chezmoi diff` separately and use `chezmoi apply` when you are ready.
GitHub Actions runs this check for pull requests targeting `main` and pushes to
`main`.

## Contents

- Zsh startup files, aliases, shell functions, environment exports, and Atuin
  shell integration
- Git and GitHub CLI configuration, plus global ignore patterns
- Vim and npm configuration
- Personal instructions for Claude Code, Cline, Continue, Cursor, GitHub
  Copilot, Gemini, and Codex
