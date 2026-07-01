#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  printf '%s\n' 'Windows config installation is only available from WSL.' >&2
  exit 1
fi

if ! command -v cmd.exe >/dev/null 2>&1; then
  printf '%s\n' 'Unable to find cmd.exe; cannot detect the Windows user.' >&2
  exit 1
fi

windows_profile="$(
  cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null \
    | tr -d '\r' \
    | sed -n '1p'
)"

if [ -z "$windows_profile" ]; then
  printf '%s\n' 'Unable to detect USERPROFILE from cmd.exe.' >&2
  exit 1
fi

if [ "${WINDOWS_USER:-}" ]; then
  windows_home="/mnt/c/Users/$WINDOWS_USER"
elif command -v wslpath >/dev/null 2>&1; then
  windows_home="$(wslpath -u "$windows_profile")"
else
  windows_home="/mnt/c/Users/${windows_profile##*\\}"
fi

if [ ! -d "$windows_home" ]; then
  printf 'Windows home not found: %s\n' "$windows_home" >&2
  exit 1
fi

copy_config() {
  local source="$1"
  local destination="$2"

  if [ ! -e "$source" ]; then
    printf 'Skipping missing Windows config source: %s\n' "$source" >&2
    return 0
  fi

  if [ -L "$source" ]; then
    printf 'Refusing to copy symlinked Windows config source: %s\n' "$source" >&2
    exit 1
  fi

  install -m 0644 "$source" "$destination"
  printf 'Installed %s\n' "$destination"
}

copy_config "$repo_dir/wezterm/.wezterm.windows.lua" "$windows_home/.wezterm.lua"
