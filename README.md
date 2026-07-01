# Dotfiles

GNU Stow-managed dotfiles for Linux and WSL. Root install commands operate on the packages listed in `Makefile`; nested vendored projects keep their own tooling.

## Quick Start

```bash
git clone https://github.com/Eiat5522/dotfiles ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

`bootstrap.sh` checks for `make` and GNU Stow, then delegates to `make install`.

## Install Commands

```bash
make install          # Restow Unix/WSL packages; also run Windows copy step in WSL
make install-wsl      # Restow Unix/WSL packages only
make install-windows  # Copy Windows-side configs from WSL into the Windows home
make uninstall        # Remove stowed Unix/WSL links
```

To restow one package manually:

```bash
stow --dir "$PWD" --target "$HOME" --restow <package>
```

## Windows-Side Configs

Windows-only files should use a `.windows.*` or `.win.*` name so root `.stow-local-ignore` keeps them out of `$HOME`.

`install-windows-configs.sh` is intentionally narrow:

- It runs only from WSL.
- It detects the Windows profile path through `cmd.exe`.
- It targets `$WINDOWS_USER` under `/mnt/c/Users` when that variable is set, otherwise the detected Windows profile path.
- It refuses to copy a symlinked source file.
- It currently copies `wezterm/.wezterm.windows.lua` to the Windows home as `.wezterm.lua` when that source exists.

Adding another Windows-side config requires both the source file and an explicit copy entry in `install-windows-configs.sh`.

## File Conventions

- Login-time Bash PATH and environment setup belongs in `bash/.bash_profile`.
- Interactive Bash behavior belongs in `bash/.bashrc`.
- Bash aliases belong in `bash/.bash_aliases`.
- Machine-local secrets and overrides belong outside the repo in `~/.bash_profile.local`.
- Linux/WSL WezTerm config is `wezterm/.wezterm.lua`; Windows-native WezTerm config is `wezterm/.wezterm.windows.lua`.

## Requirements

- GNU Stow
- make
- WSL, only for `make install-windows`
