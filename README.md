# Dotfiles Management with GNU Stow

This repository manages dotfiles for Linux/WSL2 environments with special support for WSL2 + Windows hybrid configurations.

## Quick Start

### One-Command Installation (Recommended)

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

If you prefer more control:

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
make uninstall         # Remove all symlinks
./bootstrap.sh         # One-command automated setup
```

## Requirements

- **GNU Stow**: Package manager for symlinks
  - Ubuntu/Debian: `sudo apt install stow`
  - Fedora: `sudo dnf install stow`
  - macOS: `brew install stow`

- **WSL2** (optional): Required for Windows-side config linking
