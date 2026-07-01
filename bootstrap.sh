#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v make >/dev/null 2>&1; then
  printf 'Error: make is required. Install make, then re-run %s.\n' "$0" >&2
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  printf 'Error: GNU Stow is required. Install stow, then re-run %s.\n' "$0" >&2
  exit 1
fi

exec make install
