.PHONY: check check-assistant-configs

CHEZMOI ?= chezmoi
CHEZMOI_SOURCE ?= $(CURDIR)
PROFILE_TEST_DATA := {"defaultProfile":"Default","profiles":{"default":{"tools":["codex","vscode"],"displayName":"Default"},"review":{"tools":["codex","gh","git","vscode"],"displayName":"Review Profile","name":"Profile User","email":"profile@example.test","git":{"name":"Review User","email":"review@example.test"}}}}
PROFILE_INSTRUCTION_TEST_DATA := {"profiles":{"instructions":"All profile base","additionalInstructions":"All profile addendum","inherit":{"tools":["codex"]},"empty_profile":{"tools":["codex"],"instructions":"","additionalInstructions":""},"empty_tool":{"tools":["codex"],"instructions":"Parent profile base","additionalInstructions":"Parent profile addendum","codex":{"instructions":"","additionalInstructions":""}},"specific":{"tools":["codex"],"instructions":"Specific\u0027s base","additionalInstructions":"Specific addendum"},"tool":{"tools":["codex"],"instructions":"Profile base","additionalInstructions":"Profile addendum","codex":{"instructions":"Tool base","additionalInstructions":"Tool addendum"}}}}
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
	mkdir -p "$$tmpdir/data-bootstrap-source/scripts" "$$tmpdir/data-bootstrap-source/examples/.chezmoidata"; \
	cp scripts/copy-example-data.sh "$$tmpdir/data-bootstrap-source/scripts/"; \
	cp examples/.chezmoidata/*.example "$$tmpdir/data-bootstrap-source/examples/.chezmoidata/"; \
	sh "$$tmpdir/data-bootstrap-source/scripts/copy-example-data.sh" "$$tmpdir/data-bootstrap-source" > /dev/null; \
	cmp -s examples/.chezmoidata/ai.toml.example "$$tmpdir/data-bootstrap-source/home/.chezmoidata/ai.toml"; \
	cmp -s examples/.chezmoidata/profiles.toml.example "$$tmpdir/data-bootstrap-source/home/.chezmoidata/profiles.toml"; \
	python3 -c 'import sys,tomllib; assert isinstance(tomllib.load(open(sys.argv[1], "rb"))["ai"]["instructions"], str)' "$$tmpdir/data-bootstrap-source/home/.chezmoidata/ai.toml"; \
	python3 -c 'import sys,tomllib; assert "profiles" in tomllib.load(open(sys.argv[1], "rb"))' "$$tmpdir/data-bootstrap-source/home/.chezmoidata/profiles.toml"; \
	printf '%s\n' 'Keep existing local data' > "$$tmpdir/data-bootstrap-source/home/.chezmoidata/ai.toml"; \
	sh "$$tmpdir/data-bootstrap-source/scripts/copy-example-data.sh" "$$tmpdir/data-bootstrap-source" > /dev/null; \
	grep -Fx 'Keep existing local data' "$$tmpdir/data-bootstrap-source/home/.chezmoidata/ai.toml" > /dev/null; \
	mkdir -p "$$tmpdir/profile-instruction-source/home/.chezmoiscripts" "$$tmpdir/profile-instruction-home/.codex"; \
	printf '%s\n' home > "$$tmpdir/profile-instruction-source/.chezmoiroot"; \
	printf '%s\n' 'Shared agent baseline' > "$$tmpdir/profile-instruction-home/.codex/AGENTS.md"; \
	cp home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl "$$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl"; \
	"$(CHEZMOI)" --source "$$tmpdir/profile-instruction-source" --config "$$tmpdir/chezmoi.toml" --override-data '$(PROFILE_INSTRUCTION_TEST_DATA)' execute-template --file "$$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl" > "$$tmpdir/profile-instruction-setup.sh"; \
	python3 -c 'import pathlib,sys; text=pathlib.Path(sys.argv[1]).read_text().replace("$$HOME", sys.argv[2]); pathlib.Path(sys.argv[3]).write_text(text)' "$$tmpdir/profile-instruction-setup.sh" "$$tmpdir/profile-instruction-home" "$$tmpdir/profile-instruction-setup-isolated.sh"; \
	! grep -F '/Users/sio' "$$tmpdir/profile-instruction-setup-isolated.sh" > /dev/null; \
	sh -n "$$tmpdir/profile-instruction-setup-isolated.sh"; \
	sh "$$tmpdir/profile-instruction-setup-isolated.sh"; \
	grep -Fx 'All profile base' "$$tmpdir/profile-instruction-home/.config/profiles/inherit/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'All profile addendum' "$$tmpdir/profile-instruction-home/.config/profiles/inherit/codex/AGENTS.md" > /dev/null; \
	grep -Fx "Specific's base" "$$tmpdir/profile-instruction-home/.config/profiles/specific/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'All profile addendum' "$$tmpdir/profile-instruction-home/.config/profiles/specific/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'Specific addendum' "$$tmpdir/profile-instruction-home/.config/profiles/specific/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'Tool base' "$$tmpdir/profile-instruction-home/.config/profiles/tool/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'Tool addendum' "$$tmpdir/profile-instruction-home/.config/profiles/tool/codex/AGENTS.md" > /dev/null; \
	! grep -E 'All profile|Profile base|Profile addendum' "$$tmpdir/profile-instruction-home/.config/profiles/tool/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'All profile base' "$$tmpdir/profile-instruction-home/.config/profiles/empty_profile/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'All profile addendum' "$$tmpdir/profile-instruction-home/.config/profiles/empty_profile/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'Parent profile base' "$$tmpdir/profile-instruction-home/.config/profiles/empty_tool/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'All profile addendum' "$$tmpdir/profile-instruction-home/.config/profiles/empty_tool/codex/AGENTS.md" > /dev/null; \
	grep -Fx 'Parent profile addendum' "$$tmpdir/profile-instruction-home/.config/profiles/empty_tool/codex/AGENTS.md" > /dev/null; \
	mkdir -p "$$tmpdir/empty-profile-home/.codex"; \
	printf '%s\n' 'Shared agent baseline' > "$$tmpdir/empty-profile-home/.codex/AGENTS.md"; \
	"$(CHEZMOI)" --source "$$tmpdir/profile-instruction-source" --config "$$tmpdir/chezmoi.toml" --override-data '{"profiles":{"instructions":"","additionalInstructions":"","empty":{"tools":["codex"]}}}' execute-template --file "$$tmpdir/profile-instruction-source/home/.chezmoiscripts/setup.tmpl" > "$$tmpdir/empty-profile-setup.sh"; \
	python3 -c 'import pathlib,sys; text=pathlib.Path(sys.argv[1]).read_text().replace("$$HOME", sys.argv[2]); pathlib.Path(sys.argv[3]).write_text(text)' "$$tmpdir/empty-profile-setup.sh" "$$tmpdir/empty-profile-home" "$$tmpdir/empty-profile-setup-isolated.sh"; \
	! grep -F '/Users/sio' "$$tmpdir/empty-profile-setup-isolated.sh" > /dev/null; \
	sh -n "$$tmpdir/empty-profile-setup-isolated.sh"; \
	sh "$$tmpdir/empty-profile-setup-isolated.sh"; \
	test -L "$$tmpdir/empty-profile-home/.config/profiles/empty/codex/AGENTS.md"; \
	test "$$(readlink "$$tmpdir/empty-profile-home/.config/profiles/empty/codex/AGENTS.md")" = "$$tmpdir/empty-profile-home/.codex/AGENTS.md"; \
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
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '$(PROFILE_TEST_DATA)' cat ~/.config/zsh/functions.zsh > "$$tmpdir/functions"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/functions.zsh > "$$tmpdir/functions-no-profiles"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" cat ~/.config/zsh/integrations.zsh > "$$tmpdir/integrations"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' cat ~/.config/zsh/integrations.zsh > "$$tmpdir/integrations-no-profiles"; \
	grep -F 'vscode_profile="Review Profile"' "$$tmpdir/functions" > /dev/null; \
	grep -F 'CODEX_HOME=$$HOME/.config/profiles/review/codex' "$$tmpdir/functions" > /dev/null; \
	grep -F 'CODEX_HOME=$$HOME/.config/profiles/default/codex' "$$tmpdir/functions" > /dev/null; \
	grep -F 'export GIT_CONFIG_KEY_3=user.email' "$$tmpdir/functions" > /dev/null; \
	grep -F "export GIT_CONFIG_VALUE_2='Review User'" "$$tmpdir/functions" > /dev/null; \
	grep -F "export GIT_CONFIG_VALUE_3='review@example.test'" "$$tmpdir/functions" > /dev/null; \
	grep -F 'profile-clear-environment() {' "$$tmpdir/functions" > /dev/null; \
	test "$$(grep -F -c 'profile-clear-environment' "$$tmpdir/functions")" -eq 3; \
	grep -F 'profile-enabled() {' "$$tmpdir/functions" > /dev/null; \
	! grep -F 'ai-profile-enabled' "$$tmpdir/functions" > /dev/null; \
	! grep -F 'ai-use() {' "$$tmpdir/functions" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '$(PROFILE_TEST_DATA)' execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$$tmpdir/setup-profiles.sh"; \
	grep -F '/.config/profiles"' "$$tmpdir/setup-profiles.sh" > /dev/null; \
	! grep -F 'code --profile' "$$tmpdir/setup-profiles.sh" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" --override-data '{"profiles":null}' execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$$tmpdir/setup-profiles-empty.sh"; \
	grep -F 'cli_auth_credentials_store = "file"' "$$tmpdir/setup-profiles.sh" > /dev/null; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" cat ~/.gemini/settings.json > "$$tmpdir/gemini-settings.json"; \
	mkdir -p "$$tmpdir/bin"; \
	printf '%s\n' '#!/bin/sh' '[ "$$#" -eq 2 ] && [ "$$1" = which ] && [ "$$2" = rg ] || exit 1' 'printf "%s\n" "/mise-test/ripgrep/rg"' > "$$tmpdir/bin/mise"; \
	chmod +x "$$tmpdir/bin/mise"; \
	PATH="$$tmpdir/bin:$$PATH" "$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --config "$$tmpdir/chezmoi.toml" execute-template --file 'home/private_Library/private_Application Support/private_Code/User/settings.json.tmpl' > "$$tmpdir/vscode-settings.json"; \
	python3 -m json.tool "$$tmpdir/vscode-settings.json" > /dev/null; \
	python3 -c 'import json,sys; settings=json.load(open(sys.argv[1])); keys=set(settings)-{"[jsonc]","workbench.settings.applyToAllProfiles"}; assert keys == set(settings["workbench.settings.applyToAllProfiles"]), "VS Code managed settings must be shared across profiles"; assert settings["todo-tree.ripgrep.ripgrep"] == "/mise-test/ripgrep/rg", "VS Code ripgrep path must come from mise which rg"' "$$tmpdir/vscode-settings.json"; \
	for file in home/dot_zprofile home/dot_zshrc "$$tmpdir/aliases" "$$tmpdir/aliases-no-profiles" "$$tmpdir/exports" "$$tmpdir/functions" "$$tmpdir/functions-no-profiles" "$$tmpdir/integrations" "$$tmpdir/integrations-no-profiles"; do \
	  zsh -n "$$file"; \
	done; \
	sh -n "$$tmpdir/setup-profiles.sh" "$$tmpdir/setup-profiles-empty.sh" home/.chezmoiscripts/run_after_lint-zsh.sh install.sh scripts/copy-example-data.sh; \
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
