# AGENTS

## Repo Shape
- This is a GNU Stow dotfiles repo. The root installable packages are the `STOW_PACKAGES` listed in `Makefile`, not every top-level directory.
- Some packages vendor full upstream projects under their stowed paths (for example `yazi/.config/yazi`, `earlyoom/.config/earlyoom`, `fzf/.config/.fzf`). Root commands only manage installation into `$HOME`; use nested project tooling only when you are intentionally editing those embedded projects.

## Source Of Truth
- Prefer the later definitions in `Makefile` and `install-windows-configs.sh` over `README.md` or `bootstrap.sh`.
- `Makefile` contains duplicated old targets at the top; `make` prints override warnings, but the later targets are the effective ones.
- `bootstrap.sh` currently fails `bash -n bootstrap.sh` with `syntax error: unexpected end of file`. Do not trust it as the primary verification path unless you are fixing that script.

## Commands
- Main install path: `make install`
- Linux/WSL restow only: `make install-wsl`
- Single-package restow: `stow --dir "$PWD" --target "$HOME" --restow <package>`
- Remove stowed links: `make uninstall`
- WSL-only Windows copy: `make install-windows`

## Windows Configs
- Root `.stow-local-ignore` excludes `*.windows.*` and `*.win.*`; keep Windows-only files using that naming so Stow does not link them into `$HOME`.
- Adding a Windows-only config is not enough by itself: wire the copy into `install-windows-configs.sh`.
- `install-windows-configs.sh` auto-detects `WINDOWS_USER` via `cmd.exe`, targets `/mnt/c/Users/$WINDOWS_USER`, and refuses to copy a symlinked source file.
- Today that installer only copies `wezterm/.wezterm.windows.lua` to the Windows home as `.wezterm.lua`.

## High-Signal File Conventions
- Bash split is intentional: login-time PATH/env setup belongs in `bash/.bash_profile`; interactive behavior belongs in `bash/.bashrc`; aliases belong in `bash/.bash_aliases`.
- Keep machine-local secrets or overrides out of the repo via `~/.bash_profile.local`, which `bash/.bash_profile` sources if present.
- WezTerm is split by platform: edit `wezterm/.wezterm.lua` for Linux/WSL behavior and `wezterm/.wezterm.windows.lua` for the Windows-native config copy.

## Verification
- There is no repo-wide test/lint/typecheck harness at the root.
- Verify the narrowest surface you changed: `make install-wsl` for stowed Unix files, `make install-windows` for Windows-copy logic.
- For shell changes, also run syntax checks on the touched script or config (`bash -n` for Bash files, `sh -n` for POSIX sh files).
