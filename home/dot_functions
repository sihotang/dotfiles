#!/usr/bin/env zsh

# mkcd DIRECTORY
# Create the directory and any missing parent directories, then enter it.
# Requires exactly one argument.
mkcd() {
  if (( $# != 1 )); then
    print -u2 'Usage: mkcd DIRECTORY'
    return 2
  fi

  command mkdir -p -- "$1" && builtin cd -- "$1"
}

# up [COUNT]
# Move up one or more directory levels. Defaults to one level; for example,
# `up 3` moves up three levels. The count must be a positive integer.
up() {
  local levels="${1:-1}"
  if (( $# > 1 )) || ! [[ "$levels" =~ '^[0-9]+$' ]] || (( levels < 1 )); then
    print -u2 'Usage: up [POSITIVE_NUMBER]'
    return 2
  fi

  local destination=''
  local i
  for (( i = 1; i <= levels; i++ )); do
    destination+='../'
  done
  builtin cd -- "$destination"
}

# croot
# Change to the root of the current Git repository, even when called from a
# subdirectory. Returns an error when called outside a Git repository.
croot() {
  if (( $# != 0 )); then
    print -u2 'Usage: croot'
    return 2
  fi

  local root
  root=$(command git rev-parse --show-toplevel 2>/dev/null) || {
    print -u2 'croot: not inside a Git repository'
    return 1
  }
  builtin cd -- "$root"
}

# extract ARCHIVE
# Extract one archive into the current working directory. Supports tar files
# (including .tar.gz/.tgz, .tar.bz2/.tbz2, .tar.xz/.txz, and .tar.zst/.tzst),
# zip, gzip, bzip2, and xz. Extraction follows each system utility's default
# behavior; check for filename conflicts before running it.
extract() {
  if (( $# != 1 )); then
    print -u2 'Usage: extract ARCHIVE'
    return 2
  fi

  local archive="$1"
  if [[ ! -f "$archive" ]]; then
    print -u2 "extract: file not found: $archive"
    return 1
  fi

  case "$archive" in
    *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar.zst|*.tzst)
      command tar -xf "$archive"
      ;;
    *.zip)
      command unzip "$archive"
      ;;
    *.gz)
      command gunzip "$archive"
      ;;
    *.bz2)
      command bunzip2 "$archive"
      ;;
    *.xz)
      command unxz "$archive"
      ;;
    *)
      print -u2 "extract: unsupported archive format: $archive"
      return 2
      ;;
  esac
}
