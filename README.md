# Personal dotfiles

This repository manages personal shell, command-line, editor, and AI assistant
configuration with [chezmoi](https://www.chezmoi.io/). Its shell configuration
uses Zsh.

## Getting started

On macOS, Linux, or WSL, run the POSIX shell setup script directly from GitHub:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/soparsio/dotfiles/main/setup.sh)"
```

On native Windows, run the PowerShell setup script:

```powershell
powershell -NoProfile -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/soparsio/dotfiles/main/setup.ps1')"
```

Each script installs chezmoi to a user-local directory if needed, initializes
this repository, previews the changes, and asks before applying them. Git is
required. On macOS, the shell script uses Homebrew when available and otherwise
installs chezmoi to `~/.local/bin`; it also requires `curl` for the fallback.
The PowerShell script uses PowerShell's web request support. The managed shell
configuration is for Zsh; on Windows, use WSL if you want to use that shell
configuration.

If chezmoi is already installed and you prefer to manage the steps yourself,
initialize the repository directly:

```sh
chezmoi init soparsio/dotfiles
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
`./setup.sh` on macOS, Linux, or WSL. On Windows, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
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

Review the diff before applying. You can also rerun `./setup.sh` to preview and
confirm an apply. Edit source files under `home/`; destination files in your
home directory are managed outputs.

## Machine-specific settings

Shared template defaults live in `home/.chezmoidata.yaml`. Override them with
per-machine values in `~/.config/chezmoi/chezmoi.toml`, outside this repository.
The `home/.chezmoi.toml.tmpl` seeds local `[data]` values for the detected
hostname and operating system. Add or override other values locally, for example:

```toml
[data]
ollamaHost = "127.0.0.1:11434"
workspaceDir = "Workspace"
```

`ollamaHost` configures the Ollama host used by the environment exports.
`workspaceDir` sets the directory opened by the workspace alias, relative to
your home directory. `editor` sets the default editor for Zsh and Git; it
defaults to `code --wait`.

Global mise settings live in `~/.config/mise/config.toml`; Node.js `24.21.0` is
the configured default, with Bun, the latest stable Go, and Python `3.15.2`
also managed by mise. Mise updates itself automatically. Codex CLI, Claude
Code, Gemini CLI, and GitHub Copilot CLI are installed globally through npm,
managed as mise npm tools with Bun as the package manager. After applying the
config, chezmoi installs Bun first, then runs `mise install` for configured
tools. It runs again when the mise config changes. Starship's prompt settings
live in `~/.config/starship.toml`, and Atuin settings live in
`~/.config/atuin/config.toml`. The Zsh integration sets `ATUIN_CONFIG_DIR` to
that Atuin directory. The existing `~/.atuin/config.toml` is left untouched.
Ghostty is installed as a Homebrew cask on macOS, with its config at
`~/.config/ghostty/config`.
Neovim is installed as a Homebrew formula, and its configuration reuses the
shared Vim settings at `~/.config/nvim/init.vim`.
Visual Studio Code is installed as a Homebrew cask on macOS, with portable user
settings managed at `~/Library/Application Support/Code/User/settings.json`.
Machine-specific extension paths and temporary agent instruction paths are
kept out of the shared settings.

Git settings live under `home/dot_config/git/` and are included by the managed
`~/.gitconfig`. Machine-specific Git settings belong in `~/.gitconfig.local`;
keep that file local and out of this repository.

## Profiles for CLI tools and app integrations

Configure a map of profile names to the CLI tools and app integrations enabled
for each profile in the machine-local `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
profilesDir = ".config/profiles"

[data.profiles.work]
tools = ["codex", "gh", "vscode"]
displayName = "Work"

[data.profiles.personal]
tools = ["codex", "claude", "copilot", "gemini", "gh", "antigravity", "vscode"]
displayName = "Personal"
```

Each profile is an object with a `tools` array and optional `displayName`.
Profile IDs remain the stable names used by launchers and CLI directories.
`displayName` is passed to integrations that support a separate display name;
for VS Code it selects the matching native profile. If omitted, the profile ID
is used. Convert existing array entries under `[data.profiles]` to nested
profile tables. For example:

```toml
[data.profiles.sio]
tools = ["codex", "gh", "vscode"]
displayName = "Sio"

[data.profiles.sio-shared]
tools = ["codex", "claude", "vscode"]
displayName = "Sio Shared"
```

Then `code-sio-shared` opens the VS Code profile named `Sio Shared`.

This creates directories such as `~/.config/profiles/work/codex/` and
`~/.config/profiles/personal/<cli>/`. Run `chezmoi apply` to create them and
seed shared instructions. A profile mapped to an empty tool list is removed
from `~/.config/profiles/` on apply. Profile settings and state stay outside
the repo.

Sign in to each CLI under the profile you want to use:

```sh
codex-work
codex-personal
gh-work auth login
gh-personal auth login
git-work push
git-personal push
claude-personal
copilot-personal
gemini-personal
code-work .
code-personal .
profile-use gh personal auth status
profile-use codex personal --help
```

`profile-use TOOL PROFILE [arguments…]` is the general launcher. `ai-use` stays
available as a compatibility wrapper. The generated
`<tool>-<profile>` shortcuts are equivalent. Plain CLI commands continue to
use their normal configuration directories. Gemini stores its files in a
`.gemini/` directory inside the profile's Gemini directory.

Each `gh-<profile>` launcher sets `GH_CONFIG_DIR` to
`~/.config/profiles/<profile>/gh`; run `gh-<profile> auth login` separately for
each account. The launcher removes `GH_TOKEN`, `GITHUB_TOKEN`,
`GH_ENTERPRISE_TOKEN`, and `GITHUB_ENTERPRISE_TOKEN` from its child process so
environment tokens do not override the profile's saved account. GitHub CLI
may store credentials in the operating system credential manager; the profile
directory holds the corresponding CLI configuration. See the [gh environment
variable reference](https://cli.github.com/manual/gh_help_environment).

For Git over HTTPS, `git-<profile>` runs Git with that profile's GitHub CLI
credential helper without changing global Git config. A VS Code profile with
`gh` enabled also configures the helper for plain `git` commands in its
integrated terminal. SSH remotes continue to use the SSH key selected by SSH,
so use an HTTPS remote when you want the GitHub CLI profile to choose the
account. Git 2.31 or newer is required for Git's environment-based config
overrides.

`code-<profile>` launches VS Code with the matching native VS Code profile and
environment paths for the CLI tools listed in that profile. VS Code keeps its
usual shared user data, so its primary sign-in is available across profiles;
profile-specific settings and extension selections remain managed by VS Code.
Create each native VS Code profile in the Profiles editor using **Copy from:
Default**. In the profile contents, include **Extensions** and leave **Settings**
out so the profile uses the Default profile's settings while keeping its own
extension selection. VS Code applies configuration categories omitted from a
partial profile from Default. This shares the whole Settings category; copying
Settings into a profile creates a snapshot, not a live link. For individual
settings that should stay in sync across profiles, use **Apply Setting to all
Profiles**. See the [VS Code Profiles guide](https://code.visualstudio.com/docs/configure/profiles).

Create the native profile before using `code-<profile>`: the `--profile` CLI
option creates an empty profile when the name does not exist. Chezmoi does not
install or synchronize VS Code extensions. The integrated terminal and
CLI-backed extensions inherit environment paths for the selected CLI profile.

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
instructions/settings when present. VS Code uses its native profile store;
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

The target performs these checks in order:

1. Renders the Zsh aliases and exports modules and `~/.gemini/settings.json`
   with `chezmoi cat` into a temporary directory.
2. Checks zsh syntax for `home/dot_zprofile`, `home/dot_zshrc`,
   `home/dot_config/zsh/functions.zsh`, and the rendered aliases and exports.
3. Parses the rendered Gemini settings as JSON with Python's standard library.
4. Runs `git diff --check` to catch whitespace errors in tracked changes.
5. Prints `chezmoi diff` so you can review how the source differs from the
   files in your home directory.

The command needs chezmoi, zsh, Python 3, and Git. It does not apply changes;
review the final chezmoi diff and use `chezmoi apply` when you are ready.
GitHub Actions runs this check for pull requests targeting `main` and pushes to
`main`.

## Contents

- Zsh startup files, aliases, shell functions, environment exports, and Atuin
  shell integration
- Git and GitHub CLI configuration, plus global ignore patterns
- Vim and npm configuration
- Personal instructions for Claude Code, Cline, Continue, Cursor, GitHub
  Copilot, Gemini, and Codex
