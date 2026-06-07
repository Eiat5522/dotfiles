.PHONY: help install install-wsl install-windows uninstall clean

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Available targets:"
	@echo "  make install         - Full setup (WSL + Windows configs)"
	@echo "  make install-wsl     - Install WSL configs only (using GNU Stow)"
	@echo "  make install-windows - Install Windows-side configs"
	@echo "  make uninstall       - Remove all symlinks"
	@echo "  make clean           - Clean up stow state"
	@echo ""

install: install-wsl install-windows

install-wsl:
	@echo "📦 Installing WSL configurations with GNU Stow..."
	@stow --restow */
	@echo "✓ WSL configs installed"

install-windows:
	@./install-windows-configs.sh

uninstall:
	@echo "🗑️  Removing symlinks..."
	@stow --delete */
	@echo "✓ Symlinks removed"

clean:
	@echo "🧹 Cleaning up..."
	@stow --delete */ 2>/dev/null || true
	@echo "✓ Clean complete"
