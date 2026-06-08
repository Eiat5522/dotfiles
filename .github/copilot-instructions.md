# Copilot Instructions

## Build, test, and lint commands

- `./bootstrap.sh` — primary setup entrypoint. Verifies GNU Stow is installed, runs `stow --restow */` against the repo root, and on WSL also runs the Windows config copier.
- `make install` — main install target. On WSL it runs both `install-wsl` and `install-windows`; on non-WSL it only runs `install-wsl`.
- `make install-wsl` — restow all top-level packages into `$HOME`.
- `make install-windows` — WSL-only; copies Windows-side configs into `/mnt/c/Users/$WINDOWS_USER`.
- `make uninstall` — removes stowed symlinks from `$HOME`.
- `make clean` — deletes stowed symlinks and ignores missing links.

There is no repo-wide automated test or lint target in the root docs or `Makefile`. Validate changes with the narrowest relevant install command for the surface you changed (for example `make install-wsl` for stowed Linux files or `make install-windows` for Windows-side config copies).

## High-level architecture

- This repo is a GNU Stow-based dotfiles monorepo. Top-level directories are treated as installable packages, and both `bootstrap.sh` and the root `Makefile` run `stow --dir <repo> --target "$HOME" --restow */`.
- Root metadata is deliberately kept out of Stow. The root `.stow-local-ignore` excludes documentation, installer scripts, `.github`, and Windows-only config filenames, so future changes should preserve the assumption that only package directories get stowed.
- Windows-side config files live beside their package files in the repo, use names like `.windows.*` / `.win.*`, are excluded from Stow via `.stow-local-ignore`, and are installed separately by `install-windows-configs.sh` by copying into `/mnt/c/Users/<user>`.
- Bash startup is split across multiple files: `bash/.bash_profile` does login-time PATH and environment setup, sources optional machine-local overrides from `~/.bash_profile.local`, and then sources `~/.bashrc`; `bash/.profile` only sources `~/.bashrc` when Bash reads `.profile` directly.
- `bash/.bashrc` is interactive-only and holds runtime shell behavior such as ble.sh loading, lazy NVM wrappers, directory-based `.nvmrc` switching, functions, and prompt/tool integrations. `bash/.bash_aliases` is the dedicated alias file sourced from `.bashrc`.
- WezTerm has separate Unix/WSL and Windows roles. `wezterm/.wezterm.lua` is the Linux/WSL-side config that is stowed into the Unix home directory and defines the local mux/TLS-side behavior; `wezterm/.wezterm.windows.lua` is copied to the Windows home directory as `~/.wezterm.lua` and acts as the Windows-native GUI/client-side config. Both configs use `wezterm.config_builder()` and contain mux/domain behavior directly in Lua.

## Key conventions

- Add or update shell aliases in `bash/.bash_aliases`, not directly in `bash/.bashrc`.
- Keep login-time PATH and environment setup in `bash/.bash_profile`; keep interactive shell behavior in `bash/.bashrc`. Avoid changes that would double-source `.bashrc` or move interactive-only logic into login-only files.
- Keep machine-specific secrets and overrides out of the repo by using `~/.bash_profile.local` rather than committing them into tracked bash files.
- When adding a Windows-only config, give it a `.windows.*` or `.win.*` name, add/keep the matching `.stow-local-ignore` rule, and wire the copy step into `install-windows-configs.sh` if it needs to be installed into the Windows home directory.
- Preserve the WezTerm `config_builder()` pattern and platform split: edit `wezterm/.wezterm.lua` for Linux/WSL mux/server-side behavior and `wezterm/.wezterm.windows.lua` for the Windows-native GUI/client copy. Read both if a change affects launch domains, mux behavior, connectivity, or shared keybindings.
- The Linux WezTerm config intentionally keeps extra mux/TLS domains available without auto-attaching them during startup. Treat startup connectivity as deliberate behavior, not dead code.
