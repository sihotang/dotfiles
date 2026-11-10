#!/bin/sh

set -eu

source_dir=${1:?Usage: copy-example-data.sh SOURCE_DIR}
example_dir="$source_dir/examples/.chezmoidata"
data_dir="$source_dir/home/.chezmoidata"

if [ ! -d "$example_dir" ]; then
  printf 'Example data directory not found: %s\n' "$example_dir" >&2
  exit 1
fi

mkdir -p "$data_dir"

for example_file in "$example_dir"/*.example; do
  [ -f "$example_file" ] || continue

  data_file="$data_dir/${example_file##*/}"
  data_file=${data_file%.example}
  if [ -e "$data_file" ] || [ -L "$data_file" ]; then
    continue
  fi

  cp "$example_file" "$data_file"
  printf 'Created machine-local data file: %s\n' "${data_file#"$source_dir"/}"
done
