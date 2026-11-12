#!/bin/sh

# Render and validate managed configuration in isolated temporary homes.
set -eu

CHEZMOI=${CHEZMOI:-chezmoi}
CHEZMOI_SOURCE=${CHEZMOI_SOURCE:-$PWD}
PROFILE_TEST_DATA='{"defaultProfile":"Default","profiles":{"default":{"tools":["codex","vscode"],"displayName":"Default"},"review":{"tools":["codex","gh","git","vscode"],"displayName":"Review Profile","name":"Profile User","email":"profile@example.test","git":{"name":"Review User","email":"review@example.test"}},"git_only":{"tools":["git","vscode"],"email":"git-only@example.test"}}}'
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
cmp -s examples/.chezmoidata/profiles.yaml.example "$tmpdir/data-bootstrap-source/home/.chezmoidata/profiles.yaml"
grep -Fx 'profiles:' "$tmpdir/data-bootstrap-source/home/.chezmoidata/profiles.yaml" > /dev/null
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
mkdir -p "$tmpdir/profile-gh-home/.config/profiles/review/gh" "$tmpdir/profile-gh-bin"
printf '%s\n' '#!/bin/sh' 'printf "%s\n" "${GH_TOKEN-}"' 'printf "%s\n" "${GH_CONFIG_DIR-}"' > "$tmpdir/profile-gh-bin/gh"
chmod +x "$tmpdir/profile-gh-bin/gh"
PATH="$tmpdir/profile-gh-bin:$PATH" HOME="$tmpdir/profile-gh-home" GH_TOKEN=shared-token zsh -c 'source "$1"; profile-use gh review' _ "$tmpdir/functions" > "$tmpdir/profile-gh-auth"
test -z "$(sed -n '1p' "$tmpdir/profile-gh-auth")"
grep -Fx "$tmpdir/profile-gh-home/.config/profiles/review/gh" "$tmpdir/profile-gh-auth" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" cat ~/.config/zsh/integrations.zsh > "$tmpdir/integrations"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/integrations.zsh > "$tmpdir/integrations-no-profiles"
grep -F 'vscode_profile="Review Profile"' "$tmpdir/functions" > /dev/null
grep -F 'CODEX_HOME=$HOME/.config/profiles/review/codex' "$tmpdir/functions" > /dev/null
grep -F 'CODEX_HOME=$HOME/.config/profiles/default/codex' "$tmpdir/functions" > /dev/null
grep -F 'git_config_parameters="${git_config_parameters}${git_config_parameters:+ }'\''user.name=Review User'\''"' "$tmpdir/functions" > /dev/null
grep -F 'git_config_parameters="${git_config_parameters}${git_config_parameters:+ }'\''user.email=review@example.test'\''"' "$tmpdir/functions" > /dev/null
GIT_CONFIG_COUNT=2 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_KEY_1=credential.helper GIT_CONFIG_VALUE_1=stale zsh -c 'source "$1"; profile-git-config review; test -z "${GIT_CONFIG_VALUE_0+x}"; test "$(git config user.name)" = "Review User"; test "$(git config user.email)" = "review@example.test"; git config --get-all credential.helper | grep -Fx "!gh auth git-credential" > /dev/null' _ "$tmpdir/functions"
printf '%s\n' '#!/bin/sh' 'printf "%s\n" "${GIT_CONFIG_PARAMETERS-}"' > "$tmpdir/profile-gh-bin/code"
chmod +x "$tmpdir/profile-gh-bin/code"
PATH="$tmpdir/profile-gh-bin:$PATH" zsh -c 'source "$1"; profile-use vscode git_only' _ "$tmpdir/functions" > "$tmpdir/profile-vscode-git-only"
grep -F "'user.email=git-only@example.test'" "$tmpdir/profile-vscode-git-only" > /dev/null
! grep -F 'credential.helper' "$tmpdir/profile-vscode-git-only" > /dev/null
grep -F 'profile-clear-environment() {' "$tmpdir/functions" > /dev/null
test "$(grep -F -c 'profile-clear-environment' "$tmpdir/functions")" -eq 3
grep -F 'profile-clear-gh-environment() {' "$tmpdir/functions" > /dev/null
test "$(grep -F -c 'profile-clear-gh-environment' "$tmpdir/functions")" -eq 4
! grep -F 'unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN' "$tmpdir/functions" > /dev/null
grep -F 'profile-enabled() {' "$tmpdir/functions" > /dev/null
! grep -F 'ai-profile-enabled' "$tmpdir/functions" > /dev/null
! grep -F 'ai-use() {' "$tmpdir/functions" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data "$PROFILE_TEST_DATA" execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$tmpdir/setup-profiles.sh"
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" execute-template --file home/.chezmoiscripts/darwin/run_onchange_before_install-packages.sh.tmpl > "$tmpdir/darwin-packages.sh"
if [ -s "$tmpdir/darwin-packages.sh" ]; then
  sh -n "$tmpdir/darwin-packages.sh"
  grep -Fx 'brew cleanup --prune=all' "$tmpdir/darwin-packages.sh" > /dev/null
fi
grep -F '/.config/profiles"' "$tmpdir/setup-profiles.sh" > /dev/null
! grep -F 'code --profile' "$tmpdir/setup-profiles.sh" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$tmpdir/setup-profiles-empty.sh"
grep -F 'cli_auth_credentials_store = "file"' "$tmpdir/setup-profiles.sh" > /dev/null
"$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" cat ~/.gemini/settings.json > "$tmpdir/gemini-settings.json"
mkdir -p "$tmpdir/bin"
printf '%s\n' '#!/bin/sh' '[ "$#" -eq 2 ] && [ "$1" = which ] && [ "$2" = rg ] || exit 1' 'printf "%s\n" "/mise-test/ripgrep/rg"' > "$tmpdir/bin/mise"
printf '%s\n' '#!/bin/sh' '[ "$#" -eq 2 ] && [ "$1" = --locate-extension ] && [ "$2" = continue.continue ] || exit 1' 'printf "%s\n" "/mise-test/vscode/extensions/continue.continue"' > "$tmpdir/bin/code"
chmod +x "$tmpdir/bin/mise" "$tmpdir/bin/code"
PATH="$tmpdir/bin:$PATH" "$CHEZMOI" --source "$CHEZMOI_SOURCE" --config "$tmpdir/chezmoi.toml" execute-template --file 'home/private_Library/private_Application Support/private_Code/User/settings.json.tmpl' > "$tmpdir/vscode-settings.json"
python3 -m json.tool "$tmpdir/vscode-settings.json" > /dev/null
python3 -c 'import json,sys; settings=json.load(open(sys.argv[1])); keys=set(settings)-{"yaml.schemas","workbench.settings.applyToAllProfiles"}; assert keys == set(settings["workbench.settings.applyToAllProfiles"]), "VS Code managed settings must be shared across profiles"; assert settings["todo-tree.ripgrep.ripgrep"] == "/mise-test/ripgrep/rg", "VS Code ripgrep path must come from mise which rg"; assert "file:///mise-test/vscode/extensions/continue.continue/config-yaml-schema.json" in settings["yaml.schemas"], "Continue schema path must come from code --locate-extension"' "$tmpdir/vscode-settings.json"
for file in home/dot_zprofile home/dot_zshrc "$tmpdir/aliases" "$tmpdir/aliases-no-profiles" "$tmpdir/exports" "$tmpdir/functions" "$tmpdir/functions-no-profiles" "$tmpdir/integrations" "$tmpdir/integrations-no-profiles"; do
  zsh -n "$file"
done
sh -n "$tmpdir/setup-profiles.sh" "$tmpdir/setup-profiles-empty.sh" home/.chezmoiscripts/run_after_lint-zsh.sh install.sh scripts/copy-example-data.sh
grep -Fx '#!/bin/sh' "$tmpdir/setup-profiles-empty.sh" > /dev/null
python3 -m json.tool "$tmpdir/gemini-settings.json" > /dev/null
GIT_CONFIG_PARAMETERS="'credential.helper=' 'credential.helper=!gh auth git-credential'" git config --get-all credential.helper | grep -Fx '!gh auth git-credential' > /dev/null
git diff --check
printf '%s\n' 'Repository checks passed.'
