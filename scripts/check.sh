#!/bin/sh

# Render and validate managed configuration in isolated temporary homes.
set -eu

CHEZMOI=${CHEZMOI:-chezmoi}
CHEZMOI_SOURCE=${CHEZMOI_SOURCE:-$PWD}
PROFILE_TEST_DATA='{"defaultProfile":"Default","profiles":{"default":{"tools":["codex","vscode"],"name":"Default"},"review":{"tools":["codex","gh","git","vscode"],"alias":"review-account","name":"Review Profile","email":"profile@example.test","git":{"name":"Review User","email":"review@example.test"},"gh":{"username":"review-user"}},"git_only":{"tools":["git","vscode"],"email":"git-only@example.test"},"vscode_only":{"tools":["vscode"]},"gh-default":{"tools":["gh"],"alias":"fallback-login"},"gh-git-default":{"tools":["gh","git"],"alias":"custom-alias","git":{"name":"Fallback Git","email":"fallback@example.test"}}}}'
NUMERIC_PROFILE_TEST_DATA='{"profiles":{"numeric":{"tools":["git","gh"],"alias":123,"name":123,"gh":{"username":"numeric-user"}}}}'
PROFILE_INSTRUCTION_TEST_DATA='{"profiles":{"instructions":"All profile base","inherit":{"tools":["codex"]},"empty_profile":{"tools":["codex"],"instructions":""},"empty_tool":{"tools":["codex"],"instructions":"Parent profile base","codex":{"instructions":""}},"specific":{"tools":["codex"],"instructions":"Specific\u0027s base"},"tool":{"tools":["codex"],"instructions":"Profile base","codex":{"force":true,"instructions":"Tool replacement"}}}}'
PROFILE_FORCE_TEST_DATA='{"profiles":{"instructions":"Global base","ai_append":{"tools":["codex"],"instructions":"Profile base","ai":{"force":false,"instructions":"AI append"},"codex":{"force":false,"instructions":"Codex append"}},"ai_default":{"tools":["codex"],"ai":{"instructions":"AI default append"}},"ai_force":{"tools":["codex"],"instructions":"Profile base","ai":{"force":true,"instructions":"AI replacement"}},"tool_force_false":{"tools":["codex"],"instructions":"Profile base","codex":{"force":false,"instructions":"Tool append"}},"tool_default":{"tools":["codex"],"instructions":"Tool parent base","codex":{"instructions":"Tool default append"}},"tool_force_true":{"tools":["codex"],"instructions":"Profile base","codex":{"force":true,"instructions":"Tool replacement"}}}}'

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
touch "$tmpdir/chezmoi.toml"
mkdir -p "$tmpdir/data-bootstrap-source/scripts" "$tmpdir/data-bootstrap-source/examples/.chezmoidata"
cp scripts/copy-example-data.sh "$tmpdir/data-bootstrap-source/scripts/"
cp examples/.chezmoidata/*.example "$tmpdir/data-bootstrap-source/examples/.chezmoidata/"
printf '%s\n' home > "$tmpdir/data-bootstrap-source/.chezmoiroot"
sh "$tmpdir/data-bootstrap-source/scripts/copy-example-data.sh" "$tmpdir/data-bootstrap-source" > /dev/null
cmp -s examples/.chezmoidata/ai.yaml.example "$tmpdir/data-bootstrap-source/home/.chezmoidata/ai.yaml"
cmp -s examples/.chezmoidata/profile.yaml.example "$tmpdir/data-bootstrap-source/home/.chezmoidata/profile.yaml"
grep -Fx 'profiles:' "$tmpdir/data-bootstrap-source/home/.chezmoidata/profile.yaml" > /dev/null
"$CHEZMOI" --source "$tmpdir/data-bootstrap-source" --config "$tmpdir/chezmoi.toml" data --format=json > "$tmpdir/data-bootstrap.json"
python3 -c 'import json,sys; data=json.load(open(sys.argv[1])); profiles=data["profiles"]; assert isinstance(data["ai"]["instructions"], str) and "personal" in profiles; assert profiles["personal"]["ai"]["force"] is False and isinstance(profiles["personal"]["ai"]["instructions"], str); assert profiles["personal"]["codex"]["force"] is False; assert profiles["work"]["ai"]["force"] is True and profiles["work"]["codex"]["force"] is False' "$tmpdir/data-bootstrap.json"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"name":"Your Name","email":"you@example.com"}' cat ~/.gitconfig > "$tmpdir/gitconfig"
grep -Fx '    name = "Your Name"' "$tmpdir/gitconfig" > /dev/null
grep -Fx '    email = "you@example.com"' "$tmpdir/gitconfig" > /dev/null
printf '%s\n' 'Keep existing local data' > "$tmpdir/data-bootstrap-source/home/.chezmoidata/ai.yaml"
sh "$tmpdir/data-bootstrap-source/scripts/copy-example-data.sh" "$tmpdir/data-bootstrap-source" > /dev/null
grep -Fx 'Keep existing local data' "$tmpdir/data-bootstrap-source/home/.chezmoidata/ai.yaml" > /dev/null
mkdir -p "$tmpdir/profile-instruction-source/home/.chezmoiscripts" "$tmpdir/profile-instruction-home/.codex"
printf '%s\n' home > "$tmpdir/profile-instruction-source/.chezmoiroot"
printf '%s\n' 'Shared agent baseline' > "$tmpdir/profile-instruction-home/.codex/AGENTS.md"
cp home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl "$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl"
"$CHEZMOI" --source "$tmpdir/profile-instruction-source" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_INSTRUCTION_TEST_DATA" execute-template --file "$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl" > "$tmpdir/profile-instruction-setup.sh"
python3 -c 'import pathlib,sys; text=pathlib.Path(sys.argv[1]).read_text().replace("$HOME", sys.argv[2]); pathlib.Path(sys.argv[3]).write_text(text)' "$tmpdir/profile-instruction-setup.sh" "$tmpdir/profile-instruction-home" "$tmpdir/profile-instruction-setup-isolated.sh"
! grep -F '/Users/sio' "$tmpdir/profile-instruction-setup-isolated.sh" > /dev/null
sh -n "$tmpdir/profile-instruction-setup-isolated.sh"
sh "$tmpdir/profile-instruction-setup-isolated.sh"
grep -Fx 'All profile base' "$tmpdir/profile-instruction-home/.config/profiles/inherit/codex/AGENTS.md" > /dev/null
grep -Fx "Specific's base" "$tmpdir/profile-instruction-home/.config/profiles/specific/codex/AGENTS.md" > /dev/null
grep -Fx 'Tool replacement' "$tmpdir/profile-instruction-home/.config/profiles/tool/codex/AGENTS.md" > /dev/null
mkdir -p "$tmpdir/profile-force-home/.codex"
printf '%s\n' 'Shared agent baseline' > "$tmpdir/profile-force-home/.codex/AGENTS.md"
"$CHEZMOI" --source "$tmpdir/profile-instruction-source" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_FORCE_TEST_DATA" execute-template --file "$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl" > "$tmpdir/profile-force-setup.sh"
python3 -c 'import pathlib,sys; text=pathlib.Path(sys.argv[1]).read_text().replace("$HOME", sys.argv[2]); pathlib.Path(sys.argv[3]).write_text(text)' "$tmpdir/profile-force-setup.sh" "$tmpdir/profile-force-home" "$tmpdir/profile-force-setup-isolated.sh"
sh -n "$tmpdir/profile-force-setup-isolated.sh"
sh "$tmpdir/profile-force-setup-isolated.sh"
grep -Fx 'Profile base' "$tmpdir/profile-force-home/.config/profiles/ai_append/codex/AGENTS.md" > /dev/null
grep -Fx 'AI append' "$tmpdir/profile-force-home/.config/profiles/ai_append/codex/AGENTS.md" > /dev/null
grep -Fx 'Codex append' "$tmpdir/profile-force-home/.config/profiles/ai_append/codex/AGENTS.md" > /dev/null
grep -Fx 'Global base' "$tmpdir/profile-force-home/.config/profiles/ai_default/codex/AGENTS.md" > /dev/null
grep -Fx 'AI default append' "$tmpdir/profile-force-home/.config/profiles/ai_default/codex/AGENTS.md" > /dev/null
grep -Fx 'AI replacement' "$tmpdir/profile-force-home/.config/profiles/ai_force/codex/AGENTS.md" > /dev/null
! grep -E 'Global base|Profile base' "$tmpdir/profile-force-home/.config/profiles/ai_force/codex/AGENTS.md" > /dev/null
grep -Fx 'Profile base' "$tmpdir/profile-force-home/.config/profiles/tool_force_false/codex/AGENTS.md" > /dev/null
grep -Fx 'Tool append' "$tmpdir/profile-force-home/.config/profiles/tool_force_false/codex/AGENTS.md" > /dev/null
grep -Fx 'Tool parent base' "$tmpdir/profile-force-home/.config/profiles/tool_default/codex/AGENTS.md" > /dev/null
grep -Fx 'Tool default append' "$tmpdir/profile-force-home/.config/profiles/tool_default/codex/AGENTS.md" > /dev/null
grep -Fx 'Tool replacement' "$tmpdir/profile-force-home/.config/profiles/tool_force_true/codex/AGENTS.md" > /dev/null
! grep -E 'Global base|Profile base' "$tmpdir/profile-force-home/.config/profiles/tool_force_true/codex/AGENTS.md" > /dev/null
if "$CHEZMOI" --source "$tmpdir/profile-instruction-source" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":{"bad":{"tools":["codex"],"ai":{"force":"false","instructions":"Invalid force"}}}}' execute-template --file "$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl" > "$tmpdir/invalid-force-output" 2>&1; then
  printf '%s\n' 'Invalid AI force value was accepted.' >&2
  exit 1
fi
grep -F 'must be a boolean' "$tmpdir/invalid-force-output" > /dev/null
if "$CHEZMOI" --source "$tmpdir/profile-instruction-source" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":{"bad":{"tools":["codex"],"codex":{"force":"false","instructions":"Invalid force"}}}}' execute-template --file "$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl" > "$tmpdir/invalid-tool-force-output" 2>&1; then
  printf '%s\n' 'Invalid tool force value was accepted.' >&2
  exit 1
fi
grep -F 'must be a boolean' "$tmpdir/invalid-tool-force-output" > /dev/null
grep -Fx 'All profile base' "$tmpdir/profile-instruction-home/.config/profiles/empty_profile/codex/AGENTS.md" > /dev/null
grep -Fx 'Parent profile base' "$tmpdir/profile-instruction-home/.config/profiles/empty_tool/codex/AGENTS.md" > /dev/null
mkdir -p "$tmpdir/empty-profile-home/.codex"
printf '%s\n' 'Shared agent baseline' > "$tmpdir/empty-profile-home/.codex/AGENTS.md"
mkdir -p "$tmpdir/empty-profile-home/.config/profiles/empty/codex"
printf '%s\n' '<!-- Managed by chezmoi; edit profiles.toml instead. -->' 'Old generated instructions' > "$tmpdir/empty-profile-home/.config/profiles/empty/codex/AGENTS.md"
"$CHEZMOI" --source "$tmpdir/profile-instruction-source" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":{"instructions":"","empty":{"tools":["codex"]}}}' execute-template --file "$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl" > "$tmpdir/empty-profile-setup.sh"
python3 -c 'import pathlib,sys; text=pathlib.Path(sys.argv[1]).read_text().replace("$HOME", sys.argv[2]); pathlib.Path(sys.argv[3]).write_text(text)' "$tmpdir/empty-profile-setup.sh" "$tmpdir/empty-profile-home" "$tmpdir/empty-profile-setup-isolated.sh"
! grep -F '/Users/sio' "$tmpdir/empty-profile-setup-isolated.sh" > /dev/null
sh -n "$tmpdir/empty-profile-setup-isolated.sh"
sh "$tmpdir/empty-profile-setup-isolated.sh"
test -L "$tmpdir/empty-profile-home/.config/profiles/empty/codex/AGENTS.md"
test "$(readlink "$tmpdir/empty-profile-home/.config/profiles/empty/codex/AGENTS.md")" = "$tmpdir/empty-profile-home/.codex/AGENTS.md"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_TEST_DATA" cat ~/.config/zsh/aliases.zsh > "$tmpdir/aliases"
grep -Fx "alias code='profile-use vscode Default'" "$tmpdir/aliases" > /dev/null
! grep -E "alias (git|gh)-review-account=" "$tmpdir/aliases" > /dev/null
if "$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":{"bad":{"alias":"bad alias","tools":["git"]}}}' cat ~/.config/git/config > "$tmpdir/invalid-profile-alias" 2>&1; then
  printf '%s\n' 'Invalid profile alias was accepted.' >&2
  exit 1
fi
grep -F 'invalid profile alias' "$tmpdir/invalid-profile-alias" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$NUMERIC_PROFILE_TEST_DATA" cat ~/.config/git/config > "$tmpdir/numeric-git-config"
grep -F 'profile-123 = ' "$tmpdir/numeric-git-config" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_TEST_DATA" cat ~/.config/git/config > "$tmpdir/git-config"
grep -F 'review-account = "!f() { unset GH_CONFIG_DIR GH_TOKEN' "$tmpdir/git-config" > /dev/null
grep -F 'gh auth switch --hostname github.com --user review-user' "$tmpdir/git-config" > /dev/null
grep -F 'gh auth switch --hostname github.com --user gh-git-default' "$tmpdir/git-config" > /dev/null
grep -F -- '-c user.name=\"Review User\" -c user.email=\"review@example.test\"' "$tmpdir/git-config" > /dev/null
grep -F 'git-only = "!f() { git -c user.email=\"git-only@example.test\"' "$tmpdir/git-config" > /dev/null
mkdir -p "$tmpdir/gh-bin"
printf '%s\n' '#!/bin/sh' 'exit 0' > "$tmpdir/gh-bin/gh"
chmod +x "$tmpdir/gh-bin/gh"
PATH="$tmpdir/gh-bin:$PATH" GIT_CONFIG_GLOBAL="$tmpdir/git-config" GIT_CONFIG_SYSTEM=/dev/null git review-account config user.name | grep -Fx 'Review User' > /dev/null
PATH="$tmpdir/gh-bin:$PATH" GIT_CONFIG_GLOBAL="$tmpdir/git-config" GIT_CONFIG_SYSTEM=/dev/null git review-account config user.email | grep -Fx 'review@example.test' > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_TEST_DATA" cat ~/.config/gh/config.yml > "$tmpdir/gh-config"
grep -F 'review-account: "!unset GH_CONFIG_DIR GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN GIT_CONFIG_PARAMETERS; gh auth switch --hostname github.com --user review-user' "$tmpdir/gh-config" > /dev/null
grep -F '&& GIT_CONFIG_PARAMETERS=' "$tmpdir/gh-config" > /dev/null
GIT_CONFIG_PARAMETERS="'user.name=Review User' 'user.email=review@example.test'" git config user.name | grep -Fx 'Review User' > /dev/null
GIT_CONFIG_PARAMETERS="'user.name=Review User' 'user.email=review@example.test'" git config user.email | grep -Fx 'review@example.test' > /dev/null
grep -F 'fallback-login: "!unset GH_CONFIG_DIR GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN GIT_CONFIG_PARAMETERS;' "$tmpdir/gh-config" > /dev/null
grep -F 'fallback-login: "!unset GH_CONFIG_DIR GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN GIT_CONFIG_PARAMETERS; gh auth switch --hostname github.com --user gh-default' "$tmpdir/gh-config" > /dev/null
grep -F 'custom-alias: "!unset GH_CONFIG_DIR GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN GIT_CONFIG_PARAMETERS; gh auth switch --hostname github.com --user gh-git-default' "$tmpdir/gh-config" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$NUMERIC_PROFILE_TEST_DATA" cat ~/.config/gh/config.yml > "$tmpdir/numeric-gh-config"
grep -F '"123": "!unset GH_CONFIG_DIR GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN GIT_CONFIG_PARAMETERS; gh auth switch --hostname github.com --user numeric-user' "$tmpdir/numeric-gh-config" > /dev/null
mkdir -p "$tmpdir/numeric-gh-config-dir"
cp "$tmpdir/numeric-gh-config" "$tmpdir/numeric-gh-config-dir/config.yml"
GH_CONFIG_DIR="$tmpdir/numeric-gh-config-dir" gh alias list | grep -F '123' > /dev/null
mkdir -p "$tmpdir/gh-config-dir"
cp "$tmpdir/gh-config" "$tmpdir/gh-config-dir/config.yml"
GH_CONFIG_DIR="$tmpdir/gh-config-dir" gh alias list | grep -F 'review-account' > /dev/null
mkdir -p "$tmpdir/gh-home"
printf '%s\n' '#!/bin/sh' 'printf "%s|%s|%s|%s\n" "${GH_CONFIG_DIR-}" "${GH_TOKEN-}" "$*" "${GIT_CONFIG_PARAMETERS-}" >> "$GH_TEST_LOG"' 'printf "%s\n" "${GH_CONFIG_DIR-}" "$*"' > "$tmpdir/gh-bin/gh"
chmod +x "$tmpdir/gh-bin/gh"
REAL_GH=$(command -v gh)
PATH="$tmpdir/gh-bin:$PATH" HOME="$tmpdir/gh-home" GH_CONFIG_DIR="$tmpdir/gh-config-dir" GH_TOKEN=shared-token GH_TEST_LOG="$tmpdir/gh-test-log" "$REAL_GH" review-account auth status > "$tmpdir/gh-alias-result"
grep -Fx '||auth switch --hostname github.com --user review-user|' "$tmpdir/gh-test-log" > /dev/null
grep -F '||auth status|' "$tmpdir/gh-test-log" > /dev/null
grep -F "'user.name=Review User' 'user.email=review@example.test'" "$tmpdir/gh-test-log" > /dev/null
grep -Fx 'auth status' "$tmpdir/gh-alias-result" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/aliases.zsh > "$tmpdir/aliases-no-profiles"
! grep -F 'alias dotfiles-' "$tmpdir/aliases-no-profiles" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_TEST_DATA" execute-template --init --file home/.chezmoi.yaml.tmpl > "$tmpdir/chezmoi.yaml"
grep -Fx '  defaultProfile: Default' "$tmpdir/chezmoi.yaml" > /dev/null
! grep -E '^  profiles:' "$tmpdir/chezmoi.yaml" > /dev/null
mkdir -p "$tmpdir/config-source"
"$CHEZMOI" --source "$tmpdir/config-source" --config "$tmpdir/chezmoi.yaml" data --format=json > "$tmpdir/chezmoi-config-data.json"
python3 -c 'import json,sys; data=json.load(open(sys.argv[1])); assert data["profilesDir"] == ".config/profiles" and "profiles" not in data' "$tmpdir/chezmoi-config-data.json"
grep -F "alias dotfiles='profile-use vscode Default" "$tmpdir/aliases" > /dev/null
grep -F "alias dotfiles-review='profile-use vscode review" "$tmpdir/aliases" > /dev/null
grep -F '$(dirname "$(chezmoi source-path)")' "$tmpdir/aliases" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" cat ~/.config/zsh/exports.zsh > "$tmpdir/exports"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_TEST_DATA" cat ~/.config/zsh/functions.zsh > "$tmpdir/functions"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/functions.zsh > "$tmpdir/functions-no-profiles"
! grep -E '^(profile-enabled|profile-git-config|profile-clear-environment|profile-clear-gh-environment|profile-gh-switch|profile-use-vscode|profile-use-git|profile-use-cli|profile-use)\(\)' "$tmpdir/functions-no-profiles" > /dev/null
mkdir -p "$tmpdir/profile-gh-home" "$tmpdir/profile-gh-bin"
printf '%s\n' '#!/bin/sh' 'printf "%s\n" "${GH_TOKEN-}" "${GH_CONFIG_DIR-}" "${GIT_CONFIG_PARAMETERS-}" "$*"' > "$tmpdir/profile-gh-bin/gh"
chmod +x "$tmpdir/profile-gh-bin/gh"
PATH="$tmpdir/profile-gh-bin:$PATH" HOME="$tmpdir/profile-gh-home" GH_TOKEN=shared-token zsh -c 'source "$1"; profile-use gh review auth status' _ "$tmpdir/functions" > "$tmpdir/profile-gh-auth"
test -z "$(sed -n '1p' "$tmpdir/profile-gh-auth")"
test -z "$(sed -n '2p' "$tmpdir/profile-gh-auth")"
grep -Fx 'auth switch --hostname github.com --user review-user' "$tmpdir/profile-gh-auth" > /dev/null
grep -F "'user.name=Review User' 'user.email=review@example.test'" "$tmpdir/profile-gh-auth" > /dev/null
grep -Fx 'auth status' "$tmpdir/profile-gh-auth" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" cat ~/.config/zsh/integrations.zsh > "$tmpdir/integrations"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/integrations.zsh > "$tmpdir/integrations-no-profiles"
grep -F 'vscode_profile="Review Profile"' "$tmpdir/functions" > /dev/null
grep -F 'gh-git-default) username="gh-git-default" ;;' "$tmpdir/functions" > /dev/null
grep -F 'CODEX_HOME=$HOME/.config/profiles/review/codex' "$tmpdir/functions" > /dev/null
grep -F 'CODEX_HOME=$HOME/.config/profiles/default/codex' "$tmpdir/functions" > /dev/null
grep -F 'git_config_parameters="${git_config_parameters}${git_config_parameters:+ }'\''user.name=Review User'\''"' "$tmpdir/functions" > /dev/null
grep -F 'git_config_parameters="${git_config_parameters}${git_config_parameters:+ }'\''user.email=review@example.test'\''"' "$tmpdir/functions" > /dev/null
GIT_CONFIG_COUNT=2 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_KEY_1=credential.helper GIT_CONFIG_VALUE_1=stale zsh -c 'source "$1"; profile-git-config review; test -z "${GIT_CONFIG_VALUE_0+x}"; test "$(git config user.name)" = "Review User"; test "$(git config user.email)" = "review@example.test"; git config --get-all credential.helper | grep -Fx "!gh auth git-credential" > /dev/null' _ "$tmpdir/functions"
printf '%s\n' '#!/bin/sh' 'printf "%s\n" "${GIT_CONFIG_PARAMETERS-}" "${GH_CONFIG_DIR-}" "${GH_TOKEN-}"' > "$tmpdir/profile-gh-bin/code"
chmod +x "$tmpdir/profile-gh-bin/code"
PATH="$tmpdir/profile-gh-bin:$PATH" GH_CONFIG_DIR="$tmpdir/stale-gh-config" GH_TOKEN=stale-token zsh -c 'source "$1"; profile-use vscode git_only' _ "$tmpdir/functions" > "$tmpdir/profile-vscode-git-only"
grep -F "'user.email=git-only@example.test'" "$tmpdir/profile-vscode-git-only" > /dev/null
! grep -F 'credential.helper' "$tmpdir/profile-vscode-git-only" > /dev/null
test -z "$(sed -n '2p' "$tmpdir/profile-vscode-git-only")"
test -z "$(sed -n '3p' "$tmpdir/profile-vscode-git-only")"
PATH="$tmpdir/profile-gh-bin:$PATH" GH_CONFIG_DIR="$tmpdir/stale-gh-config" GH_TOKEN=stale-token zsh -c 'source "$1"; profile-use vscode vscode_only' _ "$tmpdir/functions" > "$tmpdir/profile-vscode-only"
test -z "$(sed -n '2p' "$tmpdir/profile-vscode-only")"
test -z "$(sed -n '3p' "$tmpdir/profile-vscode-only")"
grep -F 'profile-clear-environment() {' "$tmpdir/functions" > /dev/null
test "$(grep -F -c 'profile-clear-environment' "$tmpdir/functions")" -eq 3
grep -F 'profile-clear-gh-environment() {' "$tmpdir/functions" > /dev/null
test "$(grep -F -c 'profile-clear-gh-environment' "$tmpdir/functions")" -eq 5
! grep -F 'unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN' "$tmpdir/functions" > /dev/null
grep -F 'profile-enabled() {' "$tmpdir/functions" > /dev/null
! grep -F 'ai-profile-enabled' "$tmpdir/functions" > /dev/null
! grep -F 'ai-use() {' "$tmpdir/functions" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_TEST_DATA" execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$tmpdir/setup-profiles.sh"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" execute-template --file home/.chezmoiscripts/darwin/run_onchange_before_install-packages.sh.tmpl > "$tmpdir/darwin-packages.sh"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"linux"}}' execute-template --file home/.chezmoiscripts/linux/run_onchange_before_install-packages.sh.tmpl > "$tmpdir/linux-packages.sh"
sh -n "$tmpdir/linux-packages.sh"
grep -F 'apt-get install -y ca-certificates curl git gnupg neovim zsh' "$tmpdir/linux-packages.sh" > /dev/null
grep -F 'pacman -S --needed --noconfirm' "$tmpdir/linux-packages.sh" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"windows"}}' execute-template --file home/.chezmoiscripts/windows/run_onchange_before_install-packages.ps1.tmpl > "$tmpdir/windows-packages.ps1"
test -s "$tmpdir/windows-packages.ps1"
grep -F "'jdx.mise'" "$tmpdir/windows-packages.ps1" > /dev/null
grep -F "'Microsoft.VisualStudioCode'" "$tmpdir/windows-packages.ps1" > /dev/null
grep -F "'Obsidian.Obsidian'" "$tmpdir/windows-packages.ps1" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"windows"}}' execute-template --file home/.chezmoiscripts/windows/run_onchange_after_install-mise-tools.ps1.tmpl > "$tmpdir/windows-mise-tools.ps1"
grep -F 'exec bun --' "$tmpdir/windows-mise-tools.ps1" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"windows"}}' execute-template --file home/.chezmoiscripts/windows/run_onchange_before_install-zsh.ps1.tmpl > "$tmpdir/windows-zsh.ps1"
grep -F "'zsh,git,curl'" "$tmpdir/windows-zsh.ps1" > /dev/null
grep -F 'db_shell' "$tmpdir/windows-zsh.ps1" > /dev/null
grep -F '/bin/zsh' "$tmpdir/windows-zsh.ps1" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"linux"}}' execute-template --file home/.chezmoiscripts/windows/run_onchange_before_install-zsh.ps1.tmpl > "$tmpdir/non-windows-zsh.ps1"
test ! -s "$tmpdir/non-windows-zsh.ps1"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"windows"}}' execute-template --file home/.chezmoiscripts/windows/run_onchange_after_install-oh-my-zsh.ps1.tmpl > "$tmpdir/windows-oh-my-zsh.ps1"
grep -F 'https://install.ohmyz.sh/' "$tmpdir/windows-oh-my-zsh.ps1" > /dev/null
grep -F -- '--unattended' "$tmpdir/windows-oh-my-zsh.ps1" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"linux"}}' execute-template --file home/.chezmoiscripts/windows/run_onchange_after_install-oh-my-zsh.ps1.tmpl > "$tmpdir/non-windows-oh-my-zsh.ps1"
test ! -s "$tmpdir/non-windows-oh-my-zsh.ps1"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"windows"}}' execute-template --file home/.chezmoiscripts/run_onchange_after_install-mise-tools.sh.tmpl > "$tmpdir/windows-mise-tools.sh"
test ! -s "$tmpdir/windows-mise-tools.sh"
if command -v pwsh >/dev/null 2>&1; then
  for powershell_file in \
    "$tmpdir/windows-packages.ps1" \
    "$tmpdir/windows-mise-tools.ps1" \
    "$tmpdir/windows-zsh.ps1" \
    "$tmpdir/windows-oh-my-zsh.ps1"
  do
    CHEZMOI_CHECK_FILE="$powershell_file" pwsh -NoProfile -Command '$tokens=$null; $errors=$null; [System.Management.Automation.Language.Parser]::ParseFile($env:CHEZMOI_CHECK_FILE, [ref]$tokens, [ref]$errors) > $null; if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }'
  done
fi
for os in linux darwin windows; do
  "$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "{\"chezmoi\":{\"os\":\"$os\"}}" execute-template --file home/.chezmoiscripts/linux/run_after_sync-vscode-wsl-settings.sh.tmpl > "$tmpdir/vscode-wsl-settings-$os.sh"
done
test -s "$tmpdir/vscode-wsl-settings-linux.sh"
test ! -s "$tmpdir/vscode-wsl-settings-darwin.sh"
test ! -s "$tmpdir/vscode-wsl-settings-windows.sh"
sh -n "$tmpdir/vscode-wsl-settings-linux.sh"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"windows"}}' execute-template --file home/.chezmoiignore.tmpl > "$tmpdir/ignore-windows"
grep -Fx '.config/ghostty/' "$tmpdir/ignore-windows" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"chezmoi":{"os":"linux"}}' execute-template --file home/.chezmoiignore.tmpl > "$tmpdir/ignore-linux"
! grep -Fx '.config/ghostty/' "$tmpdir/ignore-linux" > /dev/null
if [ -s "$tmpdir/darwin-packages.sh" ]; then
  sh -n "$tmpdir/darwin-packages.sh"
  grep -Fx 'brew cleanup --prune=all' "$tmpdir/darwin-packages.sh" > /dev/null
fi
grep -F '/.config/profiles"' "$tmpdir/setup-profiles.sh" > /dev/null
! grep -F 'code --profile' "$tmpdir/setup-profiles.sh" > /dev/null
! grep -F 'create_profile gh' "$tmpdir/setup-profiles.sh" > /dev/null
mkdir -p "$tmpdir/profile-cleanup-home/.config/gh" "$tmpdir/profile-cleanup-home/.config/profiles/review/gh" "$tmpdir/profile-cleanup-home/.config/profiles/git_only/gh"
touch "$tmpdir/profile-cleanup-home/.config/gh/config.yml"
ln -s "$tmpdir/profile-cleanup-home/.config/gh/config.yml" "$tmpdir/profile-cleanup-home/.config/profiles/review/gh/config.yml"
printf '%s\n' 'preserve custom account data' > "$tmpdir/profile-cleanup-home/.config/profiles/git_only/gh/hosts.yml"
mkdir -p "$tmpdir/vscode-profile-storage"
printf '%s\n' '{"sentinel":"preserve","userDataProfiles":[{"name":"Review Profile","location":"existing-review","useDefaultFlags":{"extensions":true}},{"name":"Unmanaged","location":"existing-unmanaged"}]}' > "$tmpdir/vscode-profile-storage/storage.json"
mkdir -p "$tmpdir/vscode-bin"
printf '%s\n' '#!/bin/sh' 'if [ "$1" = --version ]; then printf "%s\\n" "${CHEZMOI_VSCODE_TEST_VERSION:-1.115.0}"; exit 0; fi' 'printf "%s\\n" "$*" >> "$CHEZMOI_VSCODE_TEST_LOG"' > "$tmpdir/vscode-bin/code"
chmod +x "$tmpdir/vscode-bin/code"
HOME="$tmpdir/profile-cleanup-home" CHEZMOI_PROFILE_SETUP_TESTING=1 CHEZMOI_VSCODE_PROFILE_STORAGE_PATH="$tmpdir/vscode-profile-storage/storage.json" CHEZMOI_VSCODE_CLI="$tmpdir/vscode-bin/code" CHEZMOI_VSCODE_TEST_LOG="$tmpdir/vscode-install.log" sh "$tmpdir/setup-profiles.sh"
test ! -e "$tmpdir/profile-cleanup-home/.config/profiles/review/gh"
grep -Fx 'preserve custom account data' "$tmpdir/profile-cleanup-home/.config/profiles/git_only/gh/hosts.yml" > /dev/null
grep -Fx -- '--install-extension GitHub.copilot --profile Review Profile' "$tmpdir/vscode-install.log" > /dev/null
grep -Fx -- '--install-extension GitHub.copilot-chat --profile git_only' "$tmpdir/vscode-install.log" > /dev/null
grep -Fx -- '--install-extension GitHub.copilot' "$tmpdir/vscode-install.log" > /dev/null
printf '%s\n' '[{"id":"review","name":"Review Profile"}]' | CHEZMOI_PROFILE_SETUP_TESTING=1 CHEZMOI_VSCODE_PROFILE_STORAGE_PATH="$tmpdir/vscode-profile-storage/storage.json" CHEZMOI_VSCODE_CLI="$tmpdir/vscode-bin/code" CHEZMOI_VSCODE_TEST_VERSION=1.145.0 CHEZMOI_VSCODE_TEST_LOG="$tmpdir/vscode-builtin-install.log" python3 "$CHEZMOI_SOURCE/scripts/configure-vscode-profiles.py"
test ! -s "$tmpdir/vscode-builtin-install.log"
python3 -c 'import json,sys; data=json.load(open(sys.argv[1])); profiles=data["userDataProfiles"]; assert data["sentinel"] == "preserve"; assert len(profiles) >= 3; review=next(p for p in profiles if p["name"] == "Review Profile"); assert all(review["useDefaultFlags"][key] is True for key in ("settings","keybindings","tasks","mcp","snippets")); assert review["useDefaultFlags"]["extensions"] is False; assert any(p["name"] == "Unmanaged" for p in profiles); assert any(p["name"] == "git_only" for p in profiles); assert not any(p["name"] == "Default" for p in profiles)' "$tmpdir/vscode-profile-storage/storage.json"
python3 - "$CHEZMOI_SOURCE/scripts/configure-vscode-profiles.py" "$tmpdir" <<'PY'
import importlib.util
import os
import pathlib
import sys
from unittest import mock

script, temp = sys.argv[1:]
spec = importlib.util.spec_from_file_location("configure_vscode_profiles", script)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

# Portable installs keep their user data beside the CLI.
portable = pathlib.Path(temp) / "portable"
(portable / "bin").mkdir(parents=True)
(portable / "data" / "user-data").mkdir(parents=True)
cli = portable / "bin" / "code"
cli.touch()
assert module.storage_path(str(cli)) == (
    portable.resolve() / "data" / "user-data" / "User" / "globalStorage" / "storage.json"
)

# WSL launching Windows VS Code must use Windows APPDATA, converted to WSL form.
windows_cli = "/mnt/c/Program Files/Microsoft VS Code/bin/code"
appdata = pathlib.Path(temp) / "windows-appdata"
with mock.patch.object(module, "is_wsl", return_value=True), mock.patch.object(
    module, "windows_appdata_from_wsl", return_value=appdata
), mock.patch.dict(os.environ, {"CHEZMOI_VSCODE_VARIANT": "insiders"}):
    assert module.storage_path(windows_cli) == (
        appdata / "Code - Insiders" / "User" / "globalStorage" / "storage.json"
    )

# Native Linux stable and OSS variants honor XDG_CONFIG_HOME.
config_home = pathlib.Path(temp) / "xdg"
with mock.patch.object(module, "is_wsl", return_value=False), mock.patch.object(
    module.sys, "platform", "linux"
), mock.patch.dict(os.environ, {"XDG_CONFIG_HOME": str(config_home)}, clear=False):
    assert module.storage_path("/usr/bin/code") == (
        config_home / "Code" / "User" / "globalStorage" / "storage.json"
    )
    assert module.storage_path("/usr/bin/code-oss") == (
        config_home / "Code - OSS" / "User" / "globalStorage" / "storage.json"
    )
PY
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$tmpdir/setup-profiles-empty.sh"
grep -F 'cli_auth_credentials_store = "file"' "$tmpdir/setup-profiles.sh" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" cat ~/.gemini/settings.json > "$tmpdir/gemini-settings.json"
mkdir -p "$tmpdir/bin"
printf '%s\n' '#!/bin/sh' '[ "$#" -eq 2 ] && [ "$1" = which ] && [ "$2" = rg ] || exit 1' 'printf "%s\n" "/mise-test/ripgrep/rg"' > "$tmpdir/bin/mise"
printf '%s\n' '#!/bin/sh' '[ "$#" -eq 2 ] && [ "$1" = --locate-extension ] && [ "$2" = continue.continue ] || exit 1' 'printf "%s\n" "${CHEZMOI_VSCODE_TEST_EXTENSION_PATH:-/mise-test/vscode/extensions/continue.continue}"' > "$tmpdir/bin/code"
chmod +x "$tmpdir/bin/mise" "$tmpdir/bin/code"
PATH="$tmpdir/bin:$PATH" "$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" execute-template --file 'home/private_Library/private_Application Support/private_Code/User/settings.json.tmpl' > "$tmpdir/vscode-settings.json"
python3 -m json.tool "$tmpdir/vscode-settings.json" > /dev/null
python3 -c 'import json,sys; settings=json.load(open(sys.argv[1])); keys=set(settings)-{"yaml.schemas","workbench.settings.applyToAllProfiles"}; assert keys == set(settings["workbench.settings.applyToAllProfiles"]), "VS Code managed settings must be shared across profiles"; assert settings["todo-tree.ripgrep.ripgrep"] == "/mise-test/ripgrep/rg", "VS Code ripgrep path must come from mise which rg"; assert "file:///mise-test/vscode/extensions/continue.continue/config-yaml-schema.json" in settings["yaml.schemas"], "Continue schema path must come from code --locate-extension"' "$tmpdir/vscode-settings.json"
for template in 'home/dot_config/Code/User/settings.json.tmpl' 'home/AppData/Roaming/Code/User/settings.json.tmpl'; do
  PATH="$tmpdir/bin:$PATH" "$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" execute-template --file "$template" > "$tmpdir/vscode-platform-settings.json"
  cmp -s "$tmpdir/vscode-settings.json" "$tmpdir/vscode-platform-settings.json"
done
CHEZMOI_VSCODE_TEST_EXTENSION_PATH='C:\Users\Jane Doe\.vscode\extensions\continue.continue' PATH="$tmpdir/bin:$PATH" "$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" execute-template --file 'home/AppData/Roaming/Code/User/settings.json.tmpl' > "$tmpdir/vscode-windows-settings.json"
python3 -m json.tool "$tmpdir/vscode-windows-settings.json" > /dev/null
python3 -c 'import json,sys; settings=json.load(open(sys.argv[1])); assert "file:///C:/Users/Jane%20Doe/.vscode/extensions/continue.continue/config-yaml-schema.json" in settings["yaml.schemas"]' "$tmpdir/vscode-windows-settings.json"
for file in home/dot_zprofile home/dot_zshrc "$tmpdir/aliases" "$tmpdir/aliases-no-profiles" "$tmpdir/exports" "$tmpdir/functions" "$tmpdir/functions-no-profiles" "$tmpdir/integrations" "$tmpdir/integrations-no-profiles"; do
  zsh -n "$file"
done
sh -n "$tmpdir/setup-profiles.sh" "$tmpdir/setup-profiles-empty.sh" home/.chezmoiscripts/run_after_lint-zsh.sh install.sh scripts/copy-example-data.sh
grep -Fx '#!/bin/sh' "$tmpdir/setup-profiles-empty.sh" > /dev/null
python3 -m json.tool "$tmpdir/gemini-settings.json" > /dev/null
GIT_CONFIG_PARAMETERS="'credential.helper=' 'credential.helper=!gh auth git-credential'" git config --get-all credential.helper | grep -Fx '!gh auth git-credential' > /dev/null
git diff --check
printf '%s\n' 'Repository checks passed.'
