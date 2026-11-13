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
Zsh.

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

`chezmoi apply` installs packages with the native package manager for each
platform. macOS uses Homebrew; Linux supports apt, dnf, pacman, and zypper; and
native Windows uses WinGet. Package scripts run again when their package lists
change. The tracked `home/.chezmoidata/packages.yaml` is the package inventory
used by those scripts, including mise-managed tools and Windows Cygwin
packages. Mise itself is installed from its official installer on macOS and
Linux and from WinGet on Windows.

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
instead of `.vimrc`. Native Windows setup installs a user-local Cygwin with Zsh,
Git, and curl, configures Cygwin to use the Windows profile as its home, and
installs Oh My Zsh after applying `.zshrc`. The Cygwin Terminal shortcut starts
Zsh. WSL 2 remains an option for a full Linux environment and uses Linux paths.

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
the configured default, with Bun, the latest stable Go, ripgrep, Starship,
Atuin, and Python `3.15.2` also managed by mise. Mise self-updates on macOS and
Linux; on Windows, WinGet manages mise updates. Codex CLI, Claude Code, Gemini
CLI, and GitHub Copilot CLI are
installed globally through npm, managed as mise npm tools with Bun as the
package manager. After applying the config, chezmoi installs Bun first, then
runs `mise install` for configured tools. It runs again when the mise config
changes. Starship's prompt settings live in `~/.config/starship.toml`, and
Atuin settings live in
`~/.config/atuin/config.toml`. The Zsh integration sets `ATUIN_CONFIG_DIR` to
that Atuin directory. The existing `~/.atuin/config.toml` is left untouched.
macOS installs Ghostty, Chrome, OrbStack, Cursor, Obsidian, and Visual Studio
Code with Homebrew. Start Ollama's Homebrew service manually with
`brew services run ollama` when needed. Linux installs Ghostty when the
distribution repository provides it; Debian-based systems install Chrome,
Cursor, Obsidian, and Visual Studio Code, while DNF-based systems install
Chrome, Cursor, and Visual Studio Code. WSL skips Linux desktop applications
and uses GUI applications installed on the Windows host. Ollama is installed
with Homebrew on macOS, its official installer on Linux and WSL, and WinGet on
native Windows. OrbStack is macOS-only. Ghostty has no official Windows
application. Native Windows installs Chrome, Cursor, Obsidian, Ollama, and
Visual Studio Code with WinGet.
Neovim is installed with the platform package manager, and its configuration
reuses the shared Vim settings at `~/.config/nvim/init.vim`.
Visual Studio Code is installed with the platform package manager. Shared user
settings are managed at the standard stable VS Code settings path on macOS,
Windows, and Linux. In WSL, settings are mirrored to Windows APPDATA when the
`code` CLI resolves to a Windows installation; Linux VS Code uses the Linux
settings path. The Continue schema URI is generated from the installed
extension path. Machine-specific extension paths and temporary agent
instruction paths are kept out of the shared settings.

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

Each profile is an object with optional `alias`, `name`, `email`, and a `tools`
list. `name` and `email` are the profile-level Git identity fallback. Profile
IDs remain the stable names used by CLI directories and
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
`~/.config/profiles/personal/<tool>/` for tools with per-profile state. Each
profile that enables `gh` or `vscode` gets its own
`~/.config/profiles/<profile-id>/gh/` configuration directory. Run
`chezmoi apply` to create profile directories and seed shared instructions. A
profile mapped to an empty tool list is removed from `~/.config/profiles/` on
apply. Profile settings and state stay outside the repo.

Portable Codex defaults are kept in
`home/.chezmoitemplates/codex/config.toml` and merged into the shared
`~/.config/codex/config.toml` during profile setup. Machine-local project trust
and hook state remain in the shared file on that machine and are not committed.

Sign in through each profile's alias so the credential is stored in that
profile's GH configuration directory:

```sh
codex-work
codex-personal
gh work auth login
gh personal auth login
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

For a VS Code profile that does not enable the `gh` tool, launch that profile
with `code-<profile>` and run `gh auth login` in its integrated terminal. Each
VS Code profile still gets its own GH configuration directory.

`profile-use TOOL PROFILE [arguments…]` is the general launcher for profiled
tools; other tools' shortcuts use `<tool>-<profile>`. `gh <alias>` and
`profile-use gh PROFILE` use the profile's isolated GH configuration directory.
Sign in separately with `gh <alias> auth login` or
`profile-use gh PROFILE auth login`. Gemini stores its files in a `.gemini/`
directory inside the profile's Gemini directory.

Each native `gh <alias>` command sets `GH_CONFIG_DIR` to that profile's
directory and removes inherited `GH_TOKEN`, `GITHUB_TOKEN`,
`GH_ENTERPRISE_TOKEN`, and `GITHUB_ENTERPRISE_TOKEN` overrides. VS Code
profiles get their own GH directory even when `gh` is not listed as a profile
tool, so their integrated terminals do not fall back to the shared global
configuration.
VS Code can reuse an already running process and keep its original environment;
close all VS Code windows before switching profiles so the new process uses the
selected profile's GH directory.
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
VS Code. It also registers configured VS Code profiles in the stable VS Code
`globalStorage/storage.json` and sets Keyboard Shortcuts, Tasks, MCP Servers,
Snippets, Prompts, and Language Models to use the Default profile, except
Settings, which remain profile-specific. Extensions also stay profile specific.
This edits VS Code's internal profile state, so close all VS Code windows before
running `chezmoi apply`; the script fails rather than edit that state while VS
Code is running. It targets the standard stable VS Code data
directory for stable, Insiders, and Code OSS installations on macOS, Windows,
and Linux. In WSL, it uses Windows storage and process detection when `code`
resolves to a Windows installation. It detects portable installs with a `data`
directory beside the VS Code CLI. For a custom `--user-data-dir`, set
`CHEZMOI_VSCODE_PROFILE_STORAGE_PATH` to that directory's
`User/globalStorage/storage.json` file. Python 3 and a matching `code` CLI are
required.
VS Code 1.116 and newer include GitHub Copilot, so setup relies on the built-in
extension. Older versions install GitHub Copilot and GitHub Copilot Chat in the
Default profile and each configured VS Code profile using the `code` CLI. The
CLI must be available on `PATH`; older versions need Marketplace access.
Each configured profile gets its own settings file containing only
`chat.instructionsFilesLocations`, rendered from `settings-profile.json`;
settings are not copied from Default or preserved from an existing profile
file. The locations include the workspace directories and that profile's
`<profilesDir>/<id>/copilot` and `<profilesDir>/<id>/claude` directories.
Managed VS Code settings enable chat agents and keep
`chat.disableAIFeatures` set to `false` across all profiles.
Start each profile with
`code-<profile>` so VS Code starts with the matching CLI environment. The
VS Code `Default` profile uses Codex's default home; other profiles with
`codex` enabled use their matching `CODEX_HOME`. The managed user settings list
its shared keys in `workbench.settings.applyToAllProfiles`, so changes to those
settings in Default or another profile are applied across all profiles.
Profile-specific settings outside that list remain local. See the
[VS Code Profiles guide](https://code.visualstudio.com/docs/configure/profiles).
Other VS Code extensions remain profile specific and are not synchronized by
chezmoi. The integrated terminal and CLI-backed extensions inherit environment
paths for the selected CLI profile.

Arguments passed to `code-<profile>` go directly to VS Code; the launcher does
not create profile-specific workspace files. Fully quit every VS Code window
before switching launchers: VS Code takes environment variables from its first
running instance, so another profile opened while it is still running can keep
the first profile's `CODEX_HOME`.

Add `antigravity` to a profile's agent list to enable Google's Antigravity
extension there; it is a VS Code extension toggle and does not create a CLI
launcher.

Codex settings are shared in `~/.config/codex/config.toml`; each profile's
`codex/config.toml` links to that file. Setup merges existing profile settings
when there are no conflicting values, and stops without replacing profile
files if it finds a conflict. Settings such as project trust and hooks therefore
apply to every Codex profile. Codex profiles still have separate `CODEX_HOME`
directories and use file-based authentication, so each home keeps its own
`auth.json` and can sign in to a separate account. The setup also links the
shared Codex `AGENTS.md`, Claude `CLAUDE.md`, Copilot instructions, and Gemini
instructions/settings when present. VS Code uses its native profile store;
setup registers configured profile names there so `code-<profile>` opens the
matching profile.

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
