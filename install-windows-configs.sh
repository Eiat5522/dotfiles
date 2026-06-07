#!/bin/bash
# Automatically link Windows-side configs for WSL2

set -e

# Detect Windows username
WINDOWS_USER="${WINDOWS_USER:-$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')}"

if [ -z "$WINDOWS_USER" ]; then
    echo "❌ Error: Could not detect Windows username"
    echo "   Please set WINDOWS_USER environment variable or run from WSL2"
    exit 1
fi

WINDOWS_HOME="/mnt/c/Users/${WINDOWS_USER}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$WINDOWS_HOME" ]; then
    echo "❌ Error: Windows home directory not found: ${WINDOWS_HOME}"
    echo "   Please verify you're running from WSL2 and the username is correct"
    exit 1
fi

echo "🪟 Linking Windows-side configurations..."
echo "   Windows User: ${WINDOWS_USER}"
echo "   Windows Home: ${WINDOWS_HOME}"
echo ""

# Link WezTerm config
if [ -f "${SCRIPT_DIR}/wezterm/.wezterm.windows.lua" ]; then
    ln -sf "${SCRIPT_DIR}/wezterm/.wezterm.windows.lua" "${WINDOWS_HOME}/.wezterm.lua"
    echo "✓ WezTerm config linked: ${WINDOWS_HOME}/.wezterm.lua"
else
    echo "⚠ WezTerm Windows config not found, skipping"
fi

# Add future Windows configs here
# Example:
# if [ -f "${SCRIPT_DIR}/package/.config.windows" ]; then
#     ln -sf "${SCRIPT_DIR}/package/.config.windows" "${WINDOWS_HOME}/.config"
#     echo "✓ Package config linked"
# fi

echo ""
echo "✅ Windows configs linked successfully!"
