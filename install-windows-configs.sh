#!/bin/sh
# Copy Windows-side configs for WSL installs.

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

WINDOWS_USER=${WINDOWS_USER:-}
if [ -z "$WINDOWS_USER" ]; then
	WINDOWS_USER=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r' || true)
fi

if [ -z "$WINDOWS_USER" ]; then
	printf '%s\n' 'Error: Could not detect Windows username.'
	printf '%s\n' 'Set WINDOWS_USER or run this from WSL with cmd.exe available.'
	exit 1
fi

WINDOWS_HOME="/mnt/c/Users/${WINDOWS_USER}"

if [ ! -d "$WINDOWS_HOME" ]; then
	printf '%s\n' "Error: Windows home directory not found: ${WINDOWS_HOME}"
	printf '%s\n' 'Verify the Windows username and that /mnt/c is mounted.'
	exit 1
fi

printf '%s\n' 'Installing Windows-side configurations...'
printf '%s\n' "  Windows User: ${WINDOWS_USER}"
printf '%s\n' "  Windows Home: ${WINDOWS_HOME}"
printf '%s\n' ''

WEZTERM_SOURCE="${SCRIPT_DIR}/wezterm/.wezterm.windows.lua"
if [ -L "$WEZTERM_SOURCE" ]; then
	printf '%s\n' "Error: Refusing to install symlinked source: ${WEZTERM_SOURCE}"
	printf '%s\n' 'Replace it with a real tracked Windows config before running this installer.'
	exit 1
fi
WEZTERM_TARGET="${WINDOWS_HOME}/.wezterm.lua"

if [ ! -f "$WEZTERM_SOURCE" ]; then
	printf '%s\n' "Error: Missing source file: ${WEZTERM_SOURCE}"
	exit 1
fi

cp -f "$WEZTERM_SOURCE" "$WEZTERM_TARGET"
printf '%s\n' "WezTerm config installed: ${WEZTERM_TARGET}"
printf '%s\n' ''
printf '%s\n' 'Windows configs installed successfully.'
