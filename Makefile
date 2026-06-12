.PHONY: help install install-wsl install-windows install-wezterm-pinned uninstall clean

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
ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
IS_WSL := $(shell grep -qi microsoft /proc/version 2>/dev/null && echo 1 || echo 0)
STOW_PACKAGES := AstroNvim KickstartNvim LazyVim LunarVim NvChad Nvim atuin bash bleachbit broot coderabbit earlyoom fastfetch fzf ghostty lazygit notekami starship tealdeer wezterm yazi

help:
	@printf '%s\n' 'Dotfiles Management'
	@printf '%s\n' ''
	@printf '%s\n' 'Available targets:'
	@printf '%s\n' '  make install         - Full setup (WSL + Windows configs)'
	@printf '%s\n' '  make install-wsl     - Install WSL configs only (using GNU Stow)'
	@printf '%s\n' '  make install-windows - Install Windows-side configs'
	@printf '%s\n' '  make install-wezterm-pinned - Install pinned WezTerm version and freeze Windows updates'
	@printf '%s\n' '  make uninstall       - Remove all symlinks'
	@printf '%s\n' '  make clean           - Clean up stow state'
	@printf '%s\n' ''

ifeq ($(IS_WSL),1)
install: install-wsl install-windows
else
install: install-wsl
endif

install-wsl:
	@printf '%s\n' 'Installing WSL configurations with GNU Stow...'
	@stow --dir "$(ROOT_DIR)" --target "$$HOME" --restow $(STOW_PACKAGES)
	@printf '%s\n' 'WSL configs installed'

install-windows:
	@if [ "$(IS_WSL)" != "1" ]; then \
		printf '%s\n' 'install-windows can only run from WSL.'; \
		exit 1; \
	fi
	@./install-windows-configs.sh

install-wezterm-pinned:
	@./install-wezterm-pinned.sh

uninstall:
	@printf '%s\n' 'Removing symlinks...'
	@stow --dir "$(ROOT_DIR)" --target "$$HOME" --delete $(STOW_PACKAGES)
	@printf '%s\n' 'Symlinks removed'

clean:
	@printf '%s\n' 'Cleaning up...'
	@stow --dir "$(ROOT_DIR)" --target "$$HOME" --delete $(STOW_PACKAGES) 2>/dev/null || true
	@printf '%s\n' 'Clean complete'
