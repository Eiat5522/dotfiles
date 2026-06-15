# ~/.bash_profile: executed for login shells.

# Reuse ~/.profile when present for compatibility with other tools.
# shellcheck source=/dev/null
__BASH_PROFILE_SOURCED_PROFILE=1
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
unset __BASH_PROFILE_SOURCED_PROFILE

# PATH helpers (idempotent).
path_prepend() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) PATH="$1:$PATH" ;;
  esac
}

path_append() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) PATH="$PATH:$1" ;;
  esac
}

# Optional PATH normalization:
# - Set `PATH_CLEANUP_ENABLE=1` to enable.
# - Set `PATH_CLEANUP_KEEP_MISSING=1` to keep entries that do not exist yet.
path_normalize() {
  local old_path="$1"
  local entry cleaned=""
  declare -A seen

  IFS=':' read -r -a __path_parts <<<"$old_path"
  for entry in "${__path_parts[@]}"; do
    [ -n "$entry" ] || continue
    [ "${seen[$entry]+_}" ] && continue
    seen["$entry"]=1

    if [ "${PATH_CLEANUP_KEEP_MISSING:-0}" = "1" ] || [ -d "$entry" ]; then
      if [ -n "$cleaned" ]; then
        cleaned="$cleaned:$entry"
      else
        cleaned="$entry"
      fi
    fi
  done

  PATH="$cleaned"
}

unset JAVA_HOME
if [ -x /usr/lib/jvm/java-17-openjdk-amd64/bin/javac ]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
elif [ -x /usr/lib/jvm/default-java/bin/javac ]; then
  export JAVA_HOME="/usr/lib/jvm/default-java"
fi
[ -n "${JAVA_HOME:-}" ] && path_prepend "$JAVA_HOME/bin"

# shellcheck source=/dev/null
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
# shellcheck source=/dev/null
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
# shellcheck source=/dev/null
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
# shellcheck source=/dev/null
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

path_prepend "/usr/bin"
path_prepend "/usr/bin/wezterm-mux-server"
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/flutter/bin"
path_prepend "/usr/.local/go/bin"
path_append "$HOME/.config/nvim-linux-x86_64/bin"
if command -v wslvar >/dev/null 2>&1; then
  __windows_user_profile=$(wslvar USERPROFILE 2>/dev/null | sed 's#\\#/#g')
elif command -v cmd.exe >/dev/null 2>&1; then
  __windows_user_profile=$(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r' | sed 's#\\#/#g; s#^C:#/mnt/c#')
else
  __windows_user_profile=
fi
[ -n "$__windows_user_profile" ] && path_append "$__windows_user_profile/AppData/Roaming/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin"
unset __windows_user_profile
path_append "$HOME/android-studio/bin"
path_append "$HOME/.config/lazydocker_0.24.1_Linux_x86"
path_append "$HOME/.maestro/bin"
path_append "$HOME/.local/share/pnpm/pi"

# Keep legacy entries for specific global tools if they exist.
path_append "$HOME/.nvm/versions/node/v22.19.0/lib/node_modules/task-master-ai"
path_append "$HOME/.nvm/versions/node/v22.21.0/bin/mobilecli"
path_append "$HOME/.nvm/versions/node/v22.21.0/bin/copilot"
path_append "$HOME/.nvm/versions/node/v22.22.2/bin/copilot"
path_append "$HOME/.local/bin/hermes"
path_append "$HOME/.opencode/bin/opencode"

if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
fi

if [ -z "${XDG_DATA_HOME}" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
else
  export PNPM_HOME="$XDG_DATA_HOME/pnpm"
fi
path_prepend "$PNPM_HOME"

SDK_BASE="/mnt/d/Android/Sdk"
if [ -d "$SDK_BASE" ]; then
  export ANDROID_HOME="$SDK_BASE"
  export ANDROID_SDK_ROOT="$SDK_BASE"
  path_append "$ANDROID_HOME/platform-tools"
  path_append "$ANDROID_HOME/emulator"
  path_append "$ANDROID_HOME/cmdline-tools/latest/bin"
else
  unset ANDROID_HOME
  unset ANDROID_SDK_ROOT
fi
unset SDK_BASE

export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fdfind --type=d --hidden --strip-cwd-prefix --exclude .git "
export FZF_DEFAULT_OPTS=" --height 50% --layout=default --border --color=hl:#2dd4bf"

export CCLSP_CONFIG_PATH="$HOME/.config/claude/cclsp.json"
export EDITOR="lazy"
export CODEX_HOME="$HOME/.codex"
export CODEX_CLI_PATH="$HOME/.nvm/versions/node/v22.22.2/bin/codex"
export BROWSER="$HOME/.local/bin/wsl-browser"

# Load machine-local secrets outside the dotfiles repository.
# shellcheck source=/dev/null
[ -f "$HOME/.bash_profile.local" ] && . "$HOME/.bash_profile.local"

# Run optional PATH cleanup after all PATH mutations and local overrides.
[ "${PATH_CLEANUP_ENABLE:-0}" = "1" ] && path_normalize "$PATH"

# Startup programs should run once per interactive login session.
case $- in
*i*)
  if command -v ssh-agent >/dev/null 2>&1 && command -v ssh-add >/dev/null 2>&1; then
    pgrep -u "$USER" ssh-agent >/dev/null || eval "$(ssh-agent -s)" >/dev/null
    ssh-add -l >/dev/null 2>&1 || ssh-add "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
  fi
  ;;
esac

export PATH

# Source interactive bash customizations after login-time environment setup so
# prompt integrations can find their executables on PATH.
# shellcheck source=/dev/null
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"


SF_AC_BASH_SETUP_PATH="$HOME/.cache/sf/autocomplete/bash_setup" && test -f "$SF_AC_BASH_SETUP_PATH" && source "$SF_AC_BASH_SETUP_PATH"; # sf autocomplete setup
