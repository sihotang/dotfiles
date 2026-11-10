.PHONY: check check-assistant-configs

CHEZMOI ?= chezmoi
CHEZMOI_SOURCE ?= $(CURDIR)
PROFILE_TEST_DATA := {"defaultProfile":"Default","profiles":{"default":{"tools":["codex","vscode"],"displayName":"Default"},"review":{"tools":["codex","gh","vscode"],"displayName":"Review Profile"}}}
ASSISTANT_CONFIGS := \
	.agents/hooks.json \
	.claude/settings.json \
	.codex/hooks.json \
	.gemini/settings.json \
	.github/hooks/hooks.json

check:
	@set -eu; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	touch "$$tmpdir/chezmoi.toml"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '$(PROFILE_TEST_DATA)' cat ~/.config/zsh/aliases.zsh > "$$tmpdir/aliases"; \
	grep -Fx "alias code='profile-use vscode Default'" "$$tmpdir/aliases" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/aliases.zsh > "$$tmpdir/aliases-no-profiles"; \
	! grep -F 'alias dotfiles-' "$$tmpdir/aliases-no-profiles" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '$(PROFILE_TEST_DATA)' execute-template --init --file home/.chezmoi.toml.tmpl > "$$tmpdir/chezmoi.toml"; \
	grep -Fx '  defaultProfile = "Default"' "$$tmpdir/chezmoi.toml" > /dev/null; \
	! grep -E '^\[data\.profiles([.]|])' "$$tmpdir/chezmoi.toml" > /dev/null; \
	python3 -c 'import tomllib,sys; data=tomllib.load(open(sys.argv[1], "rb"))["data"]; assert data["profilesDir"] == ".config/profiles" and "profiles" not in data' "$$tmpdir/chezmoi.toml"; \
	grep -F "alias dotfiles='profile-use vscode Default" "$$tmpdir/aliases" > /dev/null; \
	grep -F "alias dotfiles-review='profile-use vscode review" "$$tmpdir/aliases" > /dev/null; \
	grep -F '$$(dirname "$$(chezmoi source-path)")' "$$tmpdir/aliases" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" cat ~/.config/zsh/exports.zsh > "$$tmpdir/exports"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '$(PROFILE_TEST_DATA)' cat ~/.config/zsh/integrations.zsh > "$$tmpdir/integrations"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/integrations.zsh > "$$tmpdir/integrations-no-profiles"; \
	grep -F 'vscode_profile="Review Profile"' "$$tmpdir/integrations" > /dev/null; \
	grep -F 'CODEX_HOME=$$HOME/.config/profiles/review/codex' "$$tmpdir/integrations" > /dev/null; \
	! grep -F 'CODEX_HOME=$$HOME/.config/profiles/default/codex' "$$tmpdir/integrations" > /dev/null; \
	grep -F 'unset CODEX_HOME' "$$tmpdir/integrations" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '$(PROFILE_TEST_DATA)' execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$$tmpdir/setup-profiles.sh"; \
	grep -F '/.config/profiles"' "$$tmpdir/setup-profiles.sh" > /dev/null; \
	! grep -F 'code --profile' "$$tmpdir/setup-profiles.sh" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$$tmpdir/setup-profiles-empty.sh"; \
	grep -F 'cli_auth_credentials_store = "file"' "$$tmpdir/setup-profiles.sh" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" cat ~/.gemini/settings.json > "$$tmpdir/gemini-settings.json"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" cat '~/Library/Application Support/Code/User/settings.json' > "$$tmpdir/vscode-settings.json"; \
	python3 -m json.tool "$$tmpdir/vscode-settings.json" > /dev/null; \
	python3 -c 'import json,sys; settings=json.load(open(sys.argv[1])); keys=set(settings)-{"[jsonc]","workbench.settings.applyToAllProfiles"}; assert keys == set(settings["workbench.settings.applyToAllProfiles"]), "VS Code managed settings must be shared across profiles"; assert settings["todo-tree.ripgrep.ripgrep"], "VS Code ripgrep path must not be empty"' "$$tmpdir/vscode-settings.json"; \
	for file in home/dot_zprofile home/dot_zshrc home/dot_config/zsh/functions.zsh "$$tmpdir/aliases" "$$tmpdir/aliases-no-profiles" "$$tmpdir/exports" "$$tmpdir/integrations" "$$tmpdir/integrations-no-profiles"; do \
	  zsh -n "$$file"; \
	done; \
	sh -n "$$tmpdir/setup-profiles.sh" "$$tmpdir/setup-profiles-empty.sh"; \
	grep -Fx '#!/bin/sh' "$$tmpdir/setup-profiles-empty.sh" > /dev/null; \
	python3 -m json.tool "$$tmpdir/gemini-settings.json" > /dev/null; \
	GIT_CONFIG_COUNT=2 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0= GIT_CONFIG_KEY_1=credential.helper GIT_CONFIG_VALUE_1='!gh auth git-credential' git config --get-all credential.helper | grep -Fx '!gh auth git-credential' > /dev/null; \
	git diff --check; \
	printf '%s\n' 'Repository checks passed.'

check-assistant-configs:
	@set -eu; \
	for file in $(ASSISTANT_CONFIGS); do \
	  python3 -m json.tool "$$file" > /dev/null; \
	done; \
	printf '%s\n' 'Assistant config JSON is valid.'
