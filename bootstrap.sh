#!/bin/bash
# Bootstrap script for dotfiles installation
# Automatically detects environment and sets up configurations

set -e

echo "🚀 Bootstrapping dotfiles..."
echo ""

# Detect if running in WSL
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
    echo "✓ Detected WSL2 environment"
elif [ -f /proc/version ]; then
    echo "✓ Detected Linux environment"
else
    echo "✓ Detected Unix-like environment"
fi

echo ""

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "❌ Error: GNU Stow is not installed"
    echo "   Please install it first:"
    echo "   - Ubuntu/Debian: sudo apt install stow"
    echo "   - Fedora: sudo dnf install stow"
    echo "   - macOS: brew install stow"
    exit 1
fi

# Install WSL configurations
echo "📦 Installing WSL/Linux configurations..."
stow --restow */
echo "✓ Configurations installed"
echo ""

# Install Windows configs if in WSL
if [ "$IS_WSL" = true ]; then
    echo "🪟 Setting up Windows-side configurations..."
    if [ -x "./install-windows-configs.sh" ]; then
        ./install-windows-configs.sh
    else
        echo "⚠ install-windows-configs.sh not found or not executable"
    fi
    echo ""
fi

echo "✅ Dotfiles installed successfully!"
echo ""
echo "Next steps:"
echo "  - Restart your shell or run: source ~/.bashrc"
echo "  - Review configurations in your home directory"
if [ "$IS_WSL" = true ]; then
    echo "  - Windows configs have been installed to your Windows user directory"
#!/bin/sh
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
IS_WSL=0
STOW_PACKAGES="AstroNvim KickstartNvim LazyVim LunarVim NvChad Nvim atuin bash bleachbit broot coderabbit earlyoom fastfetch fzf ghostty lazygit notekami starship tealdeer wezterm yazi"

if grep -qi microsoft /proc/version 2>/dev/null; then
	IS_WSL=1
fi

printf '%s\n' 'Bootstrapping dotfiles...'
printf '%s\n' ''

if ! command -v stow >/dev/null 2>&1; then
	printf '%s\n' 'Error: GNU Stow is not installed.'
	printf '%s\n' 'Install it first:'
	printf '%s\n' '  - Ubuntu/Debian: sudo apt install stow'
	printf '%s\n' '  - Fedora: sudo dnf install stow'
	printf '%s\n' '  - macOS: brew install stow'
	exit 1
fi

printf '%s\n' 'Installing WSL/Linux configurations...'
# shellcheck disable=SC2086
stow --dir "$SCRIPT_DIR" --target "$HOME" --restow $STOW_PACKAGES
printf '%s\n' 'Configurations installed'
printf '%s\n' ''

if [ "$IS_WSL" -eq 1 ]; then
	printf '%s\n' 'Setting up Windows-side configurations...'
	if [ -x "$SCRIPT_DIR/install-windows-configs.sh" ]; then
		"$SCRIPT_DIR/install-windows-configs.sh"
	else
		sh "$SCRIPT_DIR/install-windows-configs.sh"
	fi
	printf '%s\n' ''
fi

printf '%s\n' 'Dotfiles installed successfully.'
printf '%s\n' ''
printf '%s\n' 'Next steps:'
printf '%s\n' '  - Restart your shell or run: source ~/.bashrc'
printf '%s\n' '  - Review configurations in your home directory'
if [ "$IS_WSL" -eq 1 ]; then
	printf '%s\n' '  - Windows configs were copied to your Windows user directory'
  fi
