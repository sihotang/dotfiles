.PHONY: check check-assistant-configs lint-shell-template

CHEZMOI ?= chezmoi
CHEZMOI_SOURCE ?= $(CURDIR)
ASSISTANT_CONFIGS := \
	.agents/hooks.json \
	.claude/settings.json \
	.codex/hooks.json \
	.gemini/settings.json \
	.github/hooks/hooks.json

check:
	@CHEZMOI='$(CHEZMOI)' CHEZMOI_SOURCE='$(CHEZMOI_SOURCE)' sh scripts/check.sh
	@CHEZMOI='$(CHEZMOI)' CHEZMOI_SOURCE='$(CHEZMOI_SOURCE)' sh scripts/lint-shell-template.sh

lint-shell-template:
	@CHEZMOI='$(CHEZMOI)' CHEZMOI_SOURCE='$(CHEZMOI_SOURCE)' sh scripts/lint-shell-template.sh $(if $(filter 1 true yes,$(FIX)),--fix,) $(if $(TEMPLATE_PATH),'$(TEMPLATE_PATH)',)

check-assistant-configs:
	@set -eu; \
	for file in $(ASSISTANT_CONFIGS); do \
	  python3 -m json.tool "$$file" > /dev/null; \
	done; \
	printf '%s\n' 'Assistant config JSON is valid.'
