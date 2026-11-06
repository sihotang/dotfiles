.PHONY: check

check:
	@set -eu; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	chezmoi cat ~/.aliases > "$$tmpdir/aliases"; \
	chezmoi cat ~/.exports > "$$tmpdir/exports"; \
	chezmoi cat ~/.gemini/settings.json > "$$tmpdir/gemini-settings.json"; \
	for file in home/dot_zprofile home/dot_zshrc home/dot_functions "$$tmpdir/aliases" "$$tmpdir/exports"; do \
	  zsh -n "$$file"; \
	done; \
	python3 -m json.tool "$$tmpdir/gemini-settings.json" > /dev/null; \
	git diff --check; \
	chezmoi diff
