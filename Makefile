.PHONY: check

check:
	@set -eu; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	chezmoi cat ~/.aliases > "$$tmpdir/aliases"; \
	chezmoi cat ~/.exports > "$$tmpdir/exports"; \
	for file in home/dot_zprofile home/dot_zshrc home/dot_functions "$$tmpdir/aliases" "$$tmpdir/exports"; do \
	  zsh -n "$$file"; \
	done; \
	git diff --check; \
	chezmoi diff
