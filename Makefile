.PHONY: check check-assistant-configs

CHEZMOI ?= chezmoi
CHEZMOI_SOURCE ?= $(CURDIR)
PROFILE_TEST_DATA := {"profiles":{"review":["gh","vscode"]}}
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
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --override-data '$(PROFILE_TEST_DATA)' cat ~/.config/zsh/aliases.zsh > "$$tmpdir/aliases"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" cat ~/.config/zsh/exports.zsh > "$$tmpdir/exports"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --override-data '$(PROFILE_TEST_DATA)' cat ~/.config/zsh/integrations.zsh > "$$tmpdir/integrations"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" --override-data '$(PROFILE_TEST_DATA)' execute-template --file home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl > "$$tmpdir/setup-profiles.sh"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" cat ~/.gemini/settings.json > "$$tmpdir/gemini-settings.json"; \
	python3 -m json.tool "home/private_Library/private_Application Support/private_Code/User/settings.json" > "$$tmpdir/vscode-settings.json"; \
	for file in home/dot_zprofile home/dot_zshrc home/dot_config/zsh/functions.zsh "$$tmpdir/aliases" "$$tmpdir/exports" "$$tmpdir/integrations"; do \
	  zsh -n "$$file"; \
	done; \
	sh -n "$$tmpdir/setup-profiles.sh"; \
	python3 -m json.tool "$$tmpdir/gemini-settings.json" > /dev/null; \
	GIT_CONFIG_COUNT=2 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0= GIT_CONFIG_KEY_1=credential.helper GIT_CONFIG_VALUE_1='!gh auth git-credential' git config --get-all credential.helper | grep -Fx '!gh auth git-credential' > /dev/null; \
	git diff --check; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" diff

check-assistant-configs:
	@set -eu; \
	for file in $(ASSISTANT_CONFIGS); do \
	  python3 -m json.tool "$$file" > /dev/null; \
	done; \
	printf '%s\n' 'Assistant config JSON is valid.'
