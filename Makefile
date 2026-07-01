STOW_PACKAGES := AstroNvim atuin bash bleachbit broot coderabbit earlyoom fastfetch fzf ghostty KickstartNvim lazygit LazyVim LunarVim notekami NvChad Nvim starship tealdeer wezterm yazi
STOW_TARGET ?= $(HOME)

.PHONY: help install install-wsl install-windows uninstall

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make install          Install Unix/WSL dotfiles and Windows configs when running in WSL' \
		'  make install-wsl      Restow Unix/WSL dotfile packages into $$HOME' \
		'  make install-windows  Copy Windows-side configs from WSL into the Windows home' \
		'  make uninstall        Remove stowed Unix/WSL dotfile links from $$HOME'

install: install-wsl
	@if grep -qi microsoft /proc/version 2>/dev/null; then \
		$(MAKE) install-windows; \
	else \
		printf '%s\n' 'Not running under WSL; skipping Windows-side configs.'; \
	fi

install-wsl:
	stow --dir "$(CURDIR)" --target "$(STOW_TARGET)" --restow $(STOW_PACKAGES)

install-windows:
	./install-windows-configs.sh

uninstall:
	stow --dir "$(CURDIR)" --target "$(STOW_TARGET)" --delete $(STOW_PACKAGES)
