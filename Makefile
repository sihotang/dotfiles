.PHONY: check

check:
	@set -eu; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	chezmoi cat ~/.config/zsh/aliases.zsh > "$$tmpdir/aliases"; \
	chezmoi cat ~/.config/zsh/exports.zsh > "$$tmpdir/exports"; \
	chezmoi cat ~/.gemini/settings.json > "$$tmpdir/gemini-settings.json"; \
	for file in home/dot_zprofile home/dot_zshrc home/dot_config/zsh/functions.zsh "$$tmpdir/aliases" "$$tmpdir/exports"; do \
	  zsh -n "$$file"; \
	done; \
	python3 -m json.tool "$$tmpdir/gemini-settings.json" > /dev/null; \
	git diff --check; \
	chezmoi diff
