#!/bin/sh

# Render and lint a chezmoi template that produces a POSIX shell script.
set -eu

usage() {
  printf 'Usage: %s [--fix] [template-path]\n' "${0##*/}" >&2
}

fix=0
if [ "${1:-}" = --fix ]; then
  fix=1
  shift
fi

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
if ! command -v "$CHEZMOI" >/dev/null 2>&1; then
  if command -v chezmoi >/dev/null 2>&1; then
    CHEZMOI=chezmoi
  else
    printf 'Chezmoi executable not found: %s\n' "$CHEZMOI" >&2
    exit 127
  fi
fi

if [ "$#" -eq 1 ]; then
  selected_path=$1
  case $selected_path in
    /*) ;;
    *) selected_path="$CHEZMOI_SOURCE/$selected_path" ;;
  esac
  if [ -d "$selected_path" ]; then
    templates=$(find "$selected_path" -type f \( -name '*.sh.tmpl' -o -name '*.zsh.tmpl' \) -print)
    if [ -z "$templates" ]; then
      printf 'No shell templates found under %s\n' "$selected_path" >&2
      exit 1
    fi
  elif [ -f "$selected_path" ]; then
    templates=$selected_path
  else
    printf 'Template path not found: %s\n' "$selected_path" >&2
    exit 1
  fi
else
  templates=$(find "$CHEZMOI_SOURCE/home" -type f \( -name '*.sh.tmpl' -o -name '*.zsh.tmpl' \) -print)
  if [ -z "$templates" ]; then
    printf 'No shell templates found under %s/home\n' "$CHEZMOI_SOURCE" >&2
    exit 1
  fi
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM
touch "$tmpdir/chezmoi.toml"

normalize_whitespace() {
  python3 - "$1" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
original = path.read_bytes()
if b"\r\n" in original:
    newline = "\r\n"
elif b"\r" in original and b"\n" not in original:
    newline = "\r"
else:
    newline = "\n"
text = original.decode("utf-8")
lines = text.splitlines()
normalized = newline.join(line.rstrip(" \t") for line in lines)
if original.endswith((b"\n", b"\r")):
    normalized += newline
if normalized.encode("utf-8") != original:
    path.write_bytes(normalized.encode("utf-8"))
    print(f"Normalized whitespace: {path}")
PY
}

format_template() {
  template_path=$1
  rendered_path=$2
  shell_dialect=$3
  "$CHEZMOI" \
    --source "$CHEZMOI_SOURCE" \
    --config "$tmpdir/chezmoi.toml" \
    --override-data '{"profiles":{"lint":{"tools":["codex","gh","git","vscode"]}}}' \
    execute-template --file "$template_path" > "$rendered_path"
  shfmt -w -ln "$shell_dialect" "$rendered_path"
}

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

printf '%s\n' "$templates" | while IFS= read -r template; do
  case $template in
    /*) ;;
    *) template="$CHEZMOI_SOURCE/$template" ;;
  esac

  if [ ! -f "$template" ]; then
    printf 'Template not found: %s\n' "$template" >&2
    exit 1
  fi

  syntax_checker=sh
  case $template in
    *.zsh.tmpl) syntax_checker=${ZSH:-zsh} ;;
  esac

  if [ "$fix" -eq 1 ] && [ "$#" -eq 1 ]; then
    normalize_whitespace "$template"
  fi
  check_whitespace "$template" "$template"
  if [ "$fix" -eq 1 ] && [ "$#" -eq 0 ]; then
    continue
  fi
  if [ "$fix" -eq 1 ] && [ "$#" -eq 1 ]; then
    shell_dialect=posix
    case $template in
      *.zsh.tmpl) shell_dialect=zsh ;;
    esac
    format_template "$template" "$tmpdir/rendered.sh" "$shell_dialect"
  else
    "$CHEZMOI" \
      --source "$CHEZMOI_SOURCE" \
      --config "$tmpdir/chezmoi.toml" \
      --override-data '{"profiles":{"lint":{"tools":["codex","gh","git","vscode"]}}}' \
      execute-template --file "$template" > "$tmpdir/rendered.sh"
  fi
  check_whitespace "$tmpdir/rendered.sh" "$template (rendered)"
  "$syntax_checker" -n "$tmpdir/rendered.sh"
  printf 'Shell template lint passed: %s\n' "$template"
done
