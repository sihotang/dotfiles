#!/bin/sh

# Render and lint a chezmoi template that produces a POSIX shell script.
set -eu

usage() {
  printf 'Usage: %s [template-path]\n' "${0##*/}" >&2
}

case ${1:-} in
  -h|--help)
    usage
    exit 0
    ;;
esac

if [ "$#" -gt 1 ]; then
  usage
  exit 2
fi

CHEZMOI=${CHEZMOI:-chezmoi}
CHEZMOI_SOURCE=${CHEZMOI_SOURCE:-$PWD}
template=${1:-home/.chezmoiscripts/run_onchange_setup-profiles.sh.tmpl}
syntax_checker=sh

case $template in
  /*) ;;
  *) template="$CHEZMOI_SOURCE/$template" ;;
esac

case $template in
  *.zsh.tmpl) syntax_checker=${ZSH:-zsh} ;;
esac

if [ ! -f "$template" ]; then
  printf 'Template not found: %s\n' "$template" >&2
  exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM
touch "$tmpdir/chezmoi.toml"

check_whitespace() {
  python3 - "$1" "$2" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
label = sys.argv[2]
errors = []

for number, line in enumerate(path.read_text().splitlines(), start=1):
    if line.endswith((" ", "\t")):
        errors.append(f"{label}:{number}: trailing whitespace")
    if line and not line.strip():
        errors.append(f"{label}:{number}: whitespace-only line")

if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
PY
}

check_whitespace "$template" "$template"

"$CHEZMOI" \
  --source "$CHEZMOI_SOURCE" \
  --config "$tmpdir/chezmoi.toml" \
  --override-data '{"profiles":{"lint":{"tools":["codex","gh","git","vscode"]}}}' \
  execute-template --file "$template" > "$tmpdir/rendered.sh"

check_whitespace "$tmpdir/rendered.sh" "$template (rendered)"
"$syntax_checker" -n "$tmpdir/rendered.sh"

printf 'Shell template lint passed: %s\n' "$template"
