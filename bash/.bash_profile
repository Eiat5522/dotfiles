# ~/.bash_profile: executed for login shells.

# Environment variables belong here so they are initialized once per login
# session and inherited by child processes.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

unset JAVA_HOME
if [ -x /usr/lib/jvm/java-17-openjdk-amd64/bin/javac ]; then
	export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
elif [ -x /usr/lib/jvm/default-java/bin/javac ]; then
	export JAVA_HOME="/usr/lib/jvm/default-java"
fi

if [ -n "${JAVA_HOME:-}" ]; then
	case ":$PATH:" in
	*":$JAVA_HOME/bin:"*) ;;
	*) export PATH="$JAVA_HOME/bin:$PATH" ;;
	esac
fi

[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

case ":$PATH:" in
*":$HOME/flutter/bin:"*) ;;
*) export PATH="$HOME/flutter/bin:$PATH" ;;
esac

case ":$PATH:" in
*":$HOME/.bun/bin:"*) ;;
*) export PATH="$HOME/.bun/bin:$PATH" ;;
esac

case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) export PATH="$HOME/.local/bin:$PATH" ;;
esac

case ":$PATH:" in
*":$HOME/.config/nvim-linux-x86_64/bin:"*) ;;
*) export PATH="$PATH:$HOME/.config/nvim-linux-x86_64/bin" ;;
esac

case ":$PATH:" in
*":$HOME/.local/bin/lvim:"*) ;;
*) export PATH="$HOME/.local/bin/lvim:$PATH" ;;
esac

export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fdfind --type=d --hidden --strip-cwd-prefix --exclude .git "
export FZF_DEFAULT_OPTS=" --height 50% --layout=default --border --color=hl:#2dd4bf"

case ":$PATH:" in
*":/usr/.local/go/bin:"*) ;;
*) export PATH="/usr/.local/go/bin:$PATH" ;;
esac

case ":$PATH:" in
*":/mnt/c/Users/Dev/AppData/Roaming/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin:"*) ;;
*) export PATH="$PATH:/mnt/c/Users/Dev/AppData/Roaming/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin" ;;
esac

case ":$PATH:" in
*":/home/testuser/bin:"*) ;;
*) export PATH="/home/testuser/bin:$PATH" ;;
esac

export DOCKER_HOST="unix:///run/user/1000/docker.sock"

if [ -z "${XDG_DATA_HOME}" ]; then
	export PNPM_HOME="$HOME/.local/share/pnpm"
else
	export PNPM_HOME="$XDG_DATA_HOME/pnpm"
fi
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

case ":$PATH:" in
*":$HOME/.nvm/versions/node/v22.19.0/lib/node_modules/task-master-ai:"*) ;;
*) export PATH="$PATH:$HOME/.nvm/versions/node/v22.19.0/lib/node_modules/task-master-ai" ;;
esac

case ":$PATH:" in
*":$HOME/android-studio/bin:"*) ;;
*) export PATH="$PATH:$HOME/android-studio/bin" ;;
esac

[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

export CCLSP_CONFIG_PATH="$HOME/.config/claude/cclsp.json"
export EDITOR="lazy"

case ":$PATH:" in
*":$HOME/.config/lazydocker_0.24.1_Linux_x86:"*) ;;
*) export PATH="$PATH:$HOME/.config/lazydocker_0.24.1_Linux_x86" ;;
esac

case ":$PATH:" in
*":$HOME/bin:"*) ;;
*) export PATH="$HOME/bin:$PATH" ;;
esac

SDK_BASE="/mnt/d/Android/Sdk"
if [ -d "$SDK_BASE" ]; then
	export ANDROID_HOME="$SDK_BASE"
	export ANDROID_SDK_ROOT="$SDK_BASE"

	case ":$PATH:" in
	*":$ANDROID_HOME/platform-tools:"*) ;;
	*) export PATH="$PATH:$ANDROID_HOME/platform-tools" ;;
	esac

	case ":$PATH:" in
	*":$ANDROID_HOME/emulator:"*) ;;
	*) export PATH="$PATH:$ANDROID_HOME/emulator" ;;
	esac

	case ":$PATH:" in
	*":$ANDROID_HOME/cmdline-tools/latest/bin:"*) ;;
	*) export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin" ;;
	esac
else
	unset ANDROID_HOME
	unset ANDROID_SDK_ROOT
fi
unset SDK_BASE

case ":$PATH:" in
*":$HOME/.maestro/bin:"*) ;;
*) export PATH="$PATH:$HOME/.maestro/bin" ;;
esac

case ":$PATH:" in
*":$HOME/.nvm/versions/node/v22.21.0/bin/mobilecli:"*) ;;
*) export PATH="$PATH:$HOME/.nvm/versions/node/v22.21.0/bin/mobilecli" ;;
esac

case ":$PATH:" in
*":$HOME/.nvm/versions/node/v22.21.0/bin/copilot:"*) ;;
*) export PATH="$PATH:$HOME/.nvm/versions/node/v22.21.0/bin/copilot" ;;
esac

case ":$PATH:" in
*":$HOME/.opencode/bin:"*) ;;
*) export PATH="$HOME/.opencode/bin:$PATH" ;;
esac

export CODEX_HOME="$HOME/.codex"
export CODEX_CLI_PATH="$HOME/.nvm/versions/node/v22.22.2/bin/codex"

case ":$PATH:" in
*":$HOME/.nvm/versions/node/v22.22.2/bin/copilot:"*) ;;
*) export PATH="$PATH:$HOME/.nvm/versions/node/v22.22.2/bin/copilot" ;;
esac

case ":$PATH:" in
*":$HOME/.local/bin/hermes:"*) ;;
*) export PATH="$PATH:$HOME/.local/bin/hermes" ;;
esac

case ":$PATH:" in
*":$HOME/.opencode/bin/opencode:"*) ;;
*) export PATH="$PATH:$HOME/.opencode/bin/opencode" ;;
esac

case ":$PATH:" in
*":$HOME/.local/share/pnpm/pi:"*) ;;
*) export PATH="$PATH:$HOME/.local/share/pnpm/pi" ;;
esac

export BROWSER="$HOME/.local/bin/wsl-browser"

# Load machine-local secrets outside the dotfiles repository.
[ -f "$HOME/.bash_profile.local" ] && . "$HOME/.bash_profile.local"

# Startup programs should run once per interactive login session.
case $- in
*i*)
	if command -v ssh-agent >/dev/null 2>&1 && command -v ssh-add >/dev/null 2>&1; then
		pgrep -u "$USER" ssh-agent >/dev/null || eval "$(ssh-agent -s)" >/dev/null
		ssh-add -l >/dev/null 2>&1 || ssh-add "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
	fi
	;;
esac

if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi
