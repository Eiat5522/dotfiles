# shellcheck shell=bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything else
case $- in
*i*) ;;
*) return ;;
esac

# Keep fzf available without eagerly evaluating its shell integration.
if [[ -d "$HOME/.config/.fzf/bin" && ":$PATH:" != *":$HOME/.config/.fzf/bin:"* ]]; then
	export PATH="${PATH:+${PATH}:}$HOME/.config/.fzf/bin"
fi

# Load ble.sh early and attach late, per upstream startup guidance.
# Set BASHRC_DISABLE_BLESH=1 for one-off startup timing/debug sessions.
if [[ ${BASHRC_DISABLE_BLESH:-0} != 1 && -f "$HOME/.local/share/blesh/ble.sh" ]]; then
	__bashrc_blesh_configured=1
	# shellcheck source=/dev/null
	source -- "$HOME/.local/share/blesh/ble.sh" --attach=none --rcfile "$HOME/.dotfiles/bash/.blerc"
	if declare -F ble-attach >/dev/null; then
		__bashrc_blesh_loaded=1
	fi
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

# Alias definitions.
# maintain all aliases in the ~/.bash_aliases file, instead of adding them here directly.

if [ -f "$HOME/.bash_aliases" ]; then
	. "$HOME/.bash_aliases"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi

# Lazy-load NVM only on first use to keep interactive startup fast.
load_nvm() {
	[[ -n ${__bashrc_nvm_loaded-} ]] && return 0
	unset -f nvm node npm npx
	export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
	# shellcheck source=/dev/null
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
	# shellcheck source=/dev/null
	[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
	__bashrc_nvm_loaded=1
}

nvm() {
	load_nvm
	nvm "$@"
}
node() {
	load_nvm
	node "$@"
}
npm() {
	load_nvm
	npm "$@"
}
npx() {
	load_nvm
	npx "$@"
}

__bashrc_find_nvmrc() {
	local dir=$PWD

	while [[ $dir != / ]]; do
		if [[ -f "$dir/.nvmrc" ]]; then
			printf '%s\n' "$dir/.nvmrc"
			return 0
		fi
		dir=${dir%/*}
		[[ -n $dir ]] || dir=/
	done

	return 1
}

__bashrc_auto_nvmrc() {
	[[ -n ${__bashrc_nvm_auto_running-} ]] && return 0
	[[ $PWD == "${__bashrc_nvm_auto_pwd-}" ]] && return 0
	__bashrc_nvm_auto_pwd=$PWD

	local nvmrc_path nvmrc_value nvmrc_node_version current_node_version
	local __bashrc_nvm_auto_running=1
	nvmrc_path="$(__bashrc_find_nvmrc)" || nvmrc_path=

	if [[ -n $nvmrc_path ]]; then
		IFS= read -r nvmrc_value <"$nvmrc_path" || nvmrc_value=
		nvmrc_value=${nvmrc_value%$'\r'}
		if [[ -n $nvmrc_value ]]; then
			load_nvm
			if [[ -z ${__bashrc_nvm_auto_active-} ]]; then
				__bashrc_nvm_auto_previous_version="$(nvm version)"
			fi
			current_node_version="$(command node -v 2>/dev/null || true)"
			if [[ $nvmrc_value == "$current_node_version" || v$nvmrc_value == "$current_node_version" ]]; then
				__bashrc_nvm_auto_active=1
				return 0
			fi

			nvmrc_node_version="$(nvm version "$nvmrc_value")"
			current_node_version="$(nvm version)"

			if [[ $nvmrc_node_version == "N/A" ]]; then
				nvm install
			elif [[ $nvmrc_node_version != "$current_node_version" ]]; then
				nvm use
			fi
			__bashrc_nvm_auto_active=1
		fi
	elif [[ -n ${__bashrc_nvm_auto_active-} ]]; then
		load_nvm
		case "${__bashrc_nvm_auto_previous_version-}" in
		"" | N/A | system)
			nvm deactivate >/dev/null
			;;
		*)
			nvm use --silent "$__bashrc_nvm_auto_previous_version" >/dev/null
			;;
		esac
		unset __bashrc_nvm_auto_active
		unset __bashrc_nvm_auto_previous_version
	fi
}

cd() {
	builtin cd "$@" || return
	__bashrc_auto_nvmrc
}

pushd() {
	builtin pushd "$@" || return
	__bashrc_auto_nvmrc
}

popd() {
	builtin popd "$@" || return
	__bashrc_auto_nvmrc
}

# Yazi Shell Wrapper
function y() {
	local tmp cwd
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd <"$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd" || return
	rm -f -- "$tmp"
}

# Alias for various NeoVim Distribution
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kickstart='NVIM_APPNAME="KickstartNvim" nvim'
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias lvim="~/.local/bin/lvim"

alias lazy="nvim-lazy"

# Function for NeoVim Distribution Switcher
function nvims() {
	items=("default" "KickstartNvim" "LazyVim" "AstroNvim" "NvChad" "lvim")
	config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Switcher  " --height=~50% --layout=reverse --border --exit-0)
	if [[ -z $config ]]; then
		echo "Nothing selected"
		return 0
	elif [[ $config == "default" ]]; then
		config=""
	elif [[ $config == "lvim" ]]; then
		"$HOME/.local/bin/lvim" "$@"
		return 0
	fi
	NVIM_APPNAME=$config nvim "$@"
}
bind '"\C-a": "nvims\C-j"'

# Set up fzf key bindings and fuzzy completion

#eval "$(fzf --bash)"

# export FZF_DEFAULT_OPTS='--color=bg+:#3F3F3F,bg:#4B4B4B,border:#6B6B6B,spinner:#98BC99,hl:#719872,fg:#D9D9D9,header:#719872,info:#BDBB72,pointer:#E12672,marker:#E17899,fg+:#D9D9D9,preview-bg:#3F3F3F,prompt:#98BEDE,hl+:#98BC99'

#[ -f ~/.fzf.bash ] && source ~/.fzf.bash

#  if command -v fzf &>/dev/null; then
#  Don't source FZF shell integrations if version is older than 0.48 (Avoids `unknown option: --bash`)
#  Version comparison technique courtesy of Luciano Andress Martini:
#  https://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script
#  FZF_VERSION="$(fzf --version | cut -d' ' -f1)"
#  if [[ -f ~/.fzf.bash && "$(printf '%s\n' 0.48 "$FZF_VERSION" | sort -V | head -n1)" = 0.48 ]]; then
#    . ~/.fzf.bash
#  fi

# FZF with Git right in the shell by Junegunn : check out his github below
# Keymaps for this is available at https://github.com/junegunn/fzf-git.sh
# shellcheck source=/dev/null
[ -f "$HOME/scripts/fzf-git.sh" ] && source "$HOME/scripts/fzf-git.sh"

# fzf
# called from ~/scripts/
alias nlof='$HOME/scripts/fzf_listoldfiles.sh'
# opens documentation through fzf (eg: git,zsh etc.)
alias fman="compgen -c | fzf | xargs man"

# zoxide (called from ~/scripts/)
alias nzo='$HOME/scripts/zoxide_openfiles_nvim.sh'

# Existing Configuration for Starship
#STARSHIP_CONFIG='~/.config/starship.toml'
#
#eval "$(starship init bash)"

# --- Prompt setup: VS Code integrated terminal vs everything else ---

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
	# Don't run Starship in VS Code integrated terminal.

	# Emit OSC 7 so VS Code tracks the current working directory (CWD)
	__vscode_osc7() {
		printf $'\033]7;file://localhost%s\033\\' "$PWD"
	}

	# Ensure OSC 7 is emitted before each prompt
	# Preserve an existing PROMPT_COMMAND if you already have one.
	if [[ -n "$PROMPT_COMMAND" ]]; then
		PROMPT_COMMAND="__vscode_osc7; $PROMPT_COMMAND"
	else
		PROMPT_COMMAND="__vscode_osc7"
	fi

	# Prompt similar to your CMD example:
	# green time + purple path + newline + cyan >
	PS1='\[\e[32m\]\t\[\e[0m\] \[\e[35m\]\w\[\e[0m\]\n\[\e[36m\]>\[\e[0m\] '

else
	# Normal terminals: use Starship
	export STARSHIP_CONFIG="$HOME/.config/starship.toml"
	command -v starship &>/dev/null && eval "$(starship init bash)"
fi

######################  Starship Presents  #########################
# Uncomment to Set Starship Preset - Use ONLY ONE Preset at a time

#starship preset catppuccin-powerline -o ~/.config/starship.toml
#starship preset bracketed-segments -o ~/.config/starship.toml

# Zoxide Configuration

if command -v zoxide &>/dev/null; then
	eval "$(zoxide init bash)"
	__zoxide_cd() {
		builtin cd -- "$@" || return
		__bashrc_auto_nvmrc
	}
fi

#Configuration for thefuck
#eval $(thefuck --alias)
#You can use whatever you want as an alias, like for Mondays:
#eval $(thefuck --alias FUCK)

# Task Master aliases
alias tm='task-master'
alias taskmaster='task-master'

# alias batcat and cat to bat
alias bat="batcat"
#alias cat="batcat"

# Enable bash completion, fzf, and ble.sh
# shellcheck source=/dev/null
if [[ -z ${BASH_COMPLETION_VERSINFO-} && -f /etc/bash_completion ]]; then
	source /etc/bash_completion
elif [[ -z ${BASH_COMPLETION_VERSINFO-} && -f /usr/local/etc/bash_completion ]]; then
	# shellcheck source=/dev/null
	source /usr/local/etc/bash_completion
fi

# ble.sh handles fzf integration from ~/.dotfiles/bash/.blerc. Fall back to
# the stock fzf script only if ble.sh did not load in a real terminal.
if [[ -z ${__bashrc_blesh_loaded-} && -t 0 && -t 1 && -f ~/.fzf.bash ]]; then
	# shellcheck source=/dev/null
	source ~/.fzf.bash
fi

# Enable wezterm CLI completion
if command -v wezterm &>/dev/null; then
	# shellcheck source=/dev/null
	source <(wezterm shell-completion --shell bash)
fi

# Enable wezterm shell integration
if [ -f ~/.local/share/wezterm/wezterm.sh ]; then
	# shellcheck source=/dev/null
	. ~/.local/share/wezterm/wezterm.sh
fi

# shellcheck source=/dev/null
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

command -v atuin &>/dev/null && eval "$(atuin init bash)"

__bashrc_nvm_auto_pwd=$PWD

if [[ ${BASHRC_DISABLE_BLESH:-0} != 1 ]] && declare -F ble-attach >/dev/null; then
	ble-attach
fi
unset __bashrc_blesh_configured __bashrc_blesh_loaded

# add default keybinding for fzf-nova
bind -x '"\em": fzf-nova'

# alias for fzf-nova
alias fzf-nova='/home/eiat/.local/share/fzf-nova/fzf-nova'

# WSL: use SDK stored on Windows D: drive
if [ -d "/mnt/d/Android/Sdk" ]; then
	# Alias to run Android emulator with Windows paths (required for WSL)
	alias android-emulator='cd /mnt/d && ANDROID_SDK_ROOT="D:\Android\Sdk" ANDROID_HOME="D:\Android\Sdk" /mnt/d/Android/Sdk/emulator/emulator.exe'
fi

# CODEX bash completion
__bashrc_codex_bin=${CODEX_CLI_PATH:-}
if [[ ! -x $__bashrc_codex_bin ]]; then
	__bashrc_codex_bin=$(command -v codex 2>/dev/null || true)
fi
if [[ -n $__bashrc_codex_bin && $__bashrc_codex_bin != /mnt/c/* ]]; then
	__bashrc_codex_completion="$("$__bashrc_codex_bin" completion bash 2>/dev/null)" && eval "$__bashrc_codex_completion"
fi
unset __bashrc_codex_bin __bashrc_codex_completion

source /home/eiat/.config/broot/launcher/bash/br
