# Dot-files management with GNU Stow

Follow the below instructions to initialize GNU Stow on a Linux or WSL2 machine. For non WSL2 machines, STOP after completing step #1. For WSL2 machines, with Wezterm installed on Windows side, complete both steps.

## 1. Install & Initialize GNU Stow

```bash
git clone https://github.com/Eiat5522/dotfiles
cd ~/.dotfiles
echo wezterm 2>&1 | tee .stow-local-ignore
stow */
```

## 2. Manually copy `.wezterm.lua` to your Windows's default user folder

```bash
cp wezterm/.wezterm.lua /mnt/C/Users/<your_user_name>/.wezterm.lua
```
