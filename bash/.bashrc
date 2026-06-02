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
# Cache lesspipe output to avoid subshell on every startup.
__bashrc_lesspipe_cache="${XDG_CACHE_HOME:-$HOME/.cache}/lesspipe.cache"
if [[ -x /usr/bin/lesspipe ]]; then
  if [[ ! -f "$__bashrc_lesspipe_cache" || /usr/bin/lesspipe -nt "$__bashrc_lesspipe_cache" ]]; then
    __bashrc_lesspipe_cachedir="${__bashrc_lesspipe_cache%/*}"
    mkdir -p "$__bashrc_lesspipe_cachedir"
    if __bashrc_lesspipe_tmp="$(mktemp -p "$__bashrc_lesspipe_cachedir" lesspipe.cache.tmp.XXXXXX 2>/dev/null)"; then
      if SHELL=/bin/sh lesspipe >"$__bashrc_lesspipe_tmp" 2>/dev/null && [[ -s "$__bashrc_lesspipe_tmp" ]]; then
        mv "$__bashrc_lesspipe_tmp" "$__bashrc_lesspipe_cache"
      else
        rm -f -- "$__bashrc_lesspipe_tmp"
      fi
    fi
  fi
  if [[ -s "$__bashrc_lesspipe_cache" ]]; then
    # shellcheck source=/dev/null
    source "$__bashrc_lesspipe_cache"
  fi
fi
unset __bashrc_lesspipe_cache __bashrc_lesspipe_cachedir __bashrc_lesspipe_tmp

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

# Existing Configuration for Starship
#STARSHIP_CONFIG='~/.config/starship.toml'
#
#eval "$(starship init bash)"

# --- Prompt setup: VS Code integrated terminal vs everything else ---
# Helper: source a cached init script, regenerating if the binary is newer.
__bashrc_cached_init() {
  local cmd="$1" args="$2" cache
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/shell-init/${cmd}.bash"
  local bin
  bin="$(command -v "$cmd" 2>/dev/null)" || return 1
  if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "${cache%/*}"
    # shellcheck disable=SC2086
    "$bin" $args >"$cache" 2>/dev/null || return 1
  fi
  # shellcheck source=/dev/null
  source "$cache"
}

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
terminfoterminfo
else
  # Normal terminals: use Starship (cached init for fast startup)
  export STARSHIP_CONFIG="$HOME/.config/starship.toml"
  if command -v starship >/dev/null 2>&1; then
    __bashrc_cached_init starship "init bash"
  fi
fi

######################  Starship Presents  #########################
# Uncomment to Set Starship Preset - Use ONLY ONE Preset at a time

#starship preset catppuccin-powerline -o ~/.config/starship.toml
#starship preset bracketed-segments -o ~/.config/starship.toml

# Zoxide Configuration (cached init for fast startup)
if __bashrc_cached_init zoxide "init bash"; then
  __zoxide_cd() {
    builtin cd -- "$@" || return
    __bashrc_auto_nvmrc
  }
fi

#Configuration for thefuck
#eval $(thefuck --alias)
#You can use whatever you want as an alias, like for Mondays:
#eval $(thefuck --alias FUCK)

# Enable bash completion. When ble.sh is active, defer loading to reduce
# prompt-critical startup time; ble.sh will lazy-load completions on demand.
__bashrc_load_completions() {
  if [[ -z ${BASH_COMPLETION_VERSINFO-} && -f /etc/bash_completion ]]; then
    # shellcheck source=/dev/null
    source /etc/bash_completion
  elif [[ -z ${BASH_COMPLETION_VERSINFO-} && -f /usr/local/etc/bash_completion ]]; then
    # shellcheck source=/dev/null
    source /usr/local/etc/bash_completion
  fi
}

if [[ -n ${__bashrc_blesh_loaded-} ]]; then
  ble/util/idle.push '__bashrc_load_completions'
else
  __bashrc_load_completions
fi

# ble.sh handles fzf integration from ~/.dotfiles/bash/.blerc. Fall back to
# the stock fzf script only if ble.sh did not load in a real terminal.
if [[ -z ${__bashrc_blesh_loaded-} && -t 0 && -t 1 && -f ~/.fzf.bash ]]; then
  # shellcheck source=/dev/null
  source ~/.fzf.bash
fi

# Lazy-load wezterm CLI completion on first <Tab> for wezterm commands.
if command -v wezterm &>/dev/null; then
  _wezterm_lazy_completion() {
    unset -f _wezterm_lazy_completion
    complete -r wezterm 2>/dev/null
    # shellcheck source=/dev/null
    source <(wezterm shell-completion --shell bash)
    return 124 # retry completion
  }
  complete -F _wezterm_lazy_completion wezterm
fi

# Enable wezterm shell integration
if [ -f ~/.local/share/wezterm/wezterm.sh ]; then
  # shellcheck source=/dev/null
  . ~/.local/share/wezterm/wezterm.sh
fi

# bash-preexec: skip when ble.sh is active since ble.sh provides its own
# preexec/precmd hooks natively—loading both wastes time and can conflict.
if [[ -z ${__bashrc_blesh_loaded-} ]]; then
  # shellcheck source=/dev/null
  [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
fi

# Atuin shell history (cached init for fast startup)
if command -v atuin >/dev/null 2>&1; then
  __bashrc_cached_init atuin "init bash"
fi

__bashrc_nvm_auto_pwd=$PWD

if [[ ${BASHRC_DISABLE_BLESH:-0} != 1 ]] && declare -F ble-attach >/dev/null; then
  ble-attach
fi
unset __bashrc_blesh_configured __bashrc_blesh_loaded

# add default keybinding for fzf-nova
bind -x '"\em": fzf-nova'

# CODEX bash completion — lazy-loaded on first <Tab> to avoid subprocess at startup.
__bashrc_codex_bin=${CODEX_CLI_PATH:-}
if [[ ! -x $__bashrc_codex_bin ]]; then
  __bashrc_codex_bin=$(command -v codex 2>/dev/null || true)
fi
if [[ -n $__bashrc_codex_bin && $__bashrc_codex_bin != /mnt/c/* ]]; then
  _codex_lazy_completion() {
    unset -f _codex_lazy_completion
    complete -r codex 2>/dev/null
    local comp
    comp="$("${CODEX_CLI_PATH:-$(command -v codex)}" completion bash 2>/dev/null)" && eval "$comp"
    return 124 # retry completion
  }
  complete -F _codex_lazy_completion codex
fi
unset __bashrc_codex_bin

# Broot shell integration (conditional)
# shellcheck source=/dev/null
[[ -f "$HOME/.config/broot/launcher/bash/br" ]] && source "$HOME/.config/broot/launcher/bash/br"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

. ~/.bash.d/cht.sh

nvm use default
fastfetch


# Added by Antigravity CLI installer
export PATH="/home/eiat/.local/bin:$PATH"
