# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything else
case $- in
*i*) ;;
*) return ;;
esac

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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# aliases for cd
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias fd='fdfind'

# aliases for LazyGit
alias lgit='lazygit'
alias gits='git status'
alias gita='git add .'
alias gitc='git commit -m' # follow by "<commit message>"
alias gitpsh='git push'
alias gitpll='git pull'
alias gitpupu='git pull && git push && git status'

alias apt='sudo apt'
alias aptud='sudo apt update'
alias aptug='sudo apt upgrade'
alias aptudug='sudo apt update && apt upgrade'

# Next level of an ls
# options :  --no-filesize --no-time --no-permissions
alias ls="eza --no-filesize --long --color=always --icons=always --no-user -H"

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# tree
alias tree="tree -L 3 -a -I '.git' --gitignore --charset X "
alias dtree="tree -L 3 -a -d -I '.git' --gitignore --charset X "

# lstr
alias lstr="lstr --icons"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

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

[ -s "${NVM_DIR:-$HOME/.nvm}/bash_completion" ] && \. "${NVM_DIR:-$HOME/.nvm}/bash_completion" # This loads nvm bash_completion

# Yazi Shell Wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd <"$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
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
	NVIM_APPNAME=$config nvim $@
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
source ~/scripts/fzf-git.sh

# fzf
# called from ~/scripts/
alias nlof="~/scripts/fzf_listoldfiles.sh"
# opens documentation through fzf (eg: git,zsh etc.)
alias fman="compgen -c | fzf | xargs man"

# zoxide (called from ~/scripts/)
alias nzo="~/scripts/zoxide_openfiles_nvim.sh"

# Existing Configuration for Starship
#STARSHIP_CONFIG='~/.config/starship.toml'
#
#eval "$(starship init bash)"

# --- Prompt setup: VS Code integrated terminal vs everything else ---

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
	# Don't run Starship in VS Code integrated terminal.

	# Emit OSC 7 so VS Code tracks the current working directory (CWD)
	__vscode_osc7() {
		printf '\033]7;file://localhost%s\033\\' "$PWD"
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
	eval "$(starship init bash)"
fi

######################  Starship Presents  #########################
# Uncomment to Set Starship Preset - Use ONLY ONE Preset at a time

#starship preset catppuccin-powerline -o ~/.config/starship.toml
#starship preset bracketed-segments -o ~/.config/starship.toml

# Zoxide Configuration

eval "$(zoxide init bash)"

#Configuration for thefuck
#eval $(thefuck --alias)
#You can use whatever you want as an alias, like for Mondays:
#eval $(thefuck --alias FUCK)

# Export GitHub environment variable
# export GH_TOKEN='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'

# Task Master aliases
alias tm='task-master'
alias taskmaster='task-master'

# alias batcat and cat to bat
alias bat="batcat"
#alias cat="batcat"

# Enable bash completion, fzf, and ble.sh
[ -f /etc/bash_completion ] && source /etc/bash_completion
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.local/share/blesh/ble.sh ] && source ~/.local/share/blesh/ble.sh

# Enable wezterm CLI completion
if command -v wezterm &>/dev/null; then
	source <(wezterm shell-completion --shell bash)
fi

# Enable wezterm shell integration
if [ -f ~/.local/share/wezterm/wezterm.sh ]; then
	. ~/.local/share/wezterm/wezterm.sh
fi

# Use bash-completion, if available, and avoid double-sourcing
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

eval "$(atuin init bash)"

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
eval "$(codex completion bash)"
