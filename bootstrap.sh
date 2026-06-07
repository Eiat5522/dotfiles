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
fi
