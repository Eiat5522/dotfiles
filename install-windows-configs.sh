#!/bin/bash
# Automatically copy Windows-side configs for WSL2

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

echo "🪟 Installing Windows-side configurations..."
echo "   Windows User: ${WINDOWS_USER}"
echo "   Windows Home: ${WINDOWS_HOME}"
echo ""

# Install WezTerm config
if [ -f "${SCRIPT_DIR}/wezterm/.wezterm.windows.lua" ]; then
    TARGET_PATH="${WINDOWS_HOME}/.wezterm.lua"
    if [ -L "${TARGET_PATH}" ]; then
        rm -f "${TARGET_PATH}"
    fi
    cp -f "${SCRIPT_DIR}/wezterm/.wezterm.windows.lua" "${TARGET_PATH}"
    echo "✓ WezTerm config installed: ${TARGET_PATH}"
else
    echo "⚠ WezTerm Windows config not found, skipping"
fi

# Add future Windows configs here
# Example:
# if [ -f "${SCRIPT_DIR}/package/.config.windows" ]; then
#     cp -f "${SCRIPT_DIR}/package/.config.windows" "${WINDOWS_HOME}/.config"
#     echo "✓ Package config installed"
# fi

echo ""
echo "✅ Windows configs installed successfully!"
