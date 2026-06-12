# Dotfiles Management with GNU Stow

This repository manages dotfiles for Linux/WSL2 environments with special support for WSL2 + Windows hybrid configurations.

## Quick Start

### One-Command Installation (Recommended)

This repository manages dotfiles for Linux and WSL environments, with support for Windows-side config files.

## Quick Start

### One-Command Installation

```bash
git clone https://github.com/Eiat5522/dotfiles ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

This will automatically:

- Detect your environment (WSL2 or Linux)
- Install WSL/Linux configurations using GNU Stow
- Install Windows-side configs (if running in WSL2)

### Manual Installation

# If you prefer more control

This will:

- Detect whether you are on WSL
- Install WSL/Linux configurations using GNU Stow
- Copy Windows-side configs when running under WSL

### Manual Installation

```bash
# Install WSL/Linux configs only
make install-wsl

# Install Windows configs (WSL2 only)
make install-windows

# Or install everything
make install
```

## Managing Files on Both WSL2 and Windows

For tools that need configuration files on the Windows side (like WezTerm):

1. **Store the Windows version** in your dotfiles with a `.windows.*` suffix
   - Example: `wezterm/.wezterm.windows.lua`

2. **Prevent stowing** by adding to `.stow-local-ignore`:
   - Per-package: Add to `package/.stow-local-ignore`
   - Global: Add to root `.stow-local-ignore` with pattern `\package/.windows.*`

3. **Install automatically** using `install-windows-configs.sh`:
   - The script auto-detects your Windows username
   - Copies config files from dotfiles to your Windows home directory
   - This is not a live sync: re-run after updates to refresh Windows-side configs

4. **Extend for new tools**:
   - Add your `.windows.*` file to the appropriate package directory
   - Update `install-windows-configs.sh` to install the new file
   - Add ignore pattern to `.stow-local-ignore`

### Example: Adding a New Windows Config

```bash
# 1. Create your Windows-specific config
echo "config content" > myapp/.myapp.windows.conf

# 2. Add to package's .stow-local-ignore
echo "*.windows.*" >> myapp/.stow-local-ignore

# 3. Update install-windows-configs.sh to install it
# (Edit the script to add your copy command)

# 4. Run the installation
./install-windows-configs.sh
```

## Available Commands

```bash
make help              # Show all available commands
make install           # Full setup (WSL + Windows)
make install-wsl       # Install WSL configs only
make install-windows   # Install Windows-side configs
make install-wezterm-pinned  # Install pinned WezTerm version + freeze Windows updates
make uninstall         # Remove all symlinks
./bootstrap.sh         # One-command automated setup
```

## Pinning WezTerm Version (WSL + Windows)

This repo tracks a pinned WezTerm version in:

```bash
wezterm/VERSION
```

Install and lock that version with:

```bash
make install-wezterm-pinned
```

What this does:

- Installs the exact pinned Linux/WSL `wezterm-nightly` build into `~/.local/opt/wezterm-<version>`
- Updates symlinks in `~/.local/bin` (`wezterm`, `wezterm-gui`, `wezterm-mux-server`)
- On WSL, applies Windows-side freeze controls (best effort): `scoop hold wezterm` and `winget pin`

To change versions, update `wezterm/VERSION` and re-run `make install-wezterm-pinned`.

## Requirements

- **GNU Stow**: Package manager for symlinks
  - Ubuntu/Debian: `sudo apt install stow`
  - Fedora: `sudo dnf install stow`
  - macOS: `brew install stow`

- **WSL2** (optional): Required for Windows-side config linking

# Install Windows configs (WSL only)

make install-windows

# Install everything

make install

````

## Managing Windows-side Files

For tools that need a Windows copy of a config file, keep the source file in the repo with a `.windows.*` suffix.

1. Put the Windows-specific file in the package directory.
2. Keep it out of stow by adding the pattern to the package's `.stow-local-ignore` file.
3. Re-run `./bootstrap.sh` or `make install-windows` whenever you update the file.

### Example

```bash
wezterm/.wezterm.windows.lua
````

## Notes on Stow Ignores

- Use `.stow-local-ignore` for package-local ignore rules.
- Use `.stow-global-ignore` if you need a repo-wide ignore list for GNU Stow.
- The root `.stow-local-ignore` in this repo is used for repo-level patterns that should not be stowed.

## Requirements

- GNU Stow
- WSL if you want the Windows-side config installer
