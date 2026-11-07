.PHONY: check

CHEZMOI ?= chezmoi
CHEZMOI_SOURCE ?= $(CURDIR)

check:
	@set -eu; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" cat ~/.config/zsh/aliases.zsh > "$$tmpdir/aliases"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" cat ~/.config/zsh/exports.zsh > "$$tmpdir/exports"; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" cat ~/.gemini/settings.json > "$$tmpdir/gemini-settings.json"; \
	for file in home/dot_zprofile home/dot_zshrc home/dot_config/zsh/functions.zsh "$$tmpdir/aliases" "$$tmpdir/exports"; do \
	  zsh -n "$$file"; \
	done; \
	python3 -m json.tool "$$tmpdir/gemini-settings.json" > /dev/null; \
	git diff --check; \
	"$(CHEZMOI)" --source "$(CHEZMOI_SOURCE)" diff
