# Maintain all aliases here:

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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='eza --color=auto --icons=auto --show-hidden --group-directories-first'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Next level of an ls
# options :  --no-filesize --no-time --no-permissions
alias ls="eza -x --color=always --icons=always --no-filesize --no-user --no-permissions --no-time -G -H --group-directories-first --all"

# some more ls aliases
alias ll='eza -al --classify=always --color=always --icons=always --no-filesize --no-user --no-permissions --no-time --group-directories-first -h'
alias la='eza -al --group-directories-first -h'

# tree
alias tree="tree -L 3 -a -I '.git' --gitignore --charset X "
alias dtree="tree -L 3 -a -d -I '.git' --gitignore --charset X "

# lstr
alias lstr="lstr --icons"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Task Master aliases
alias tm='task-master'
alias taskmaster='task-master'

# alias batcat and cat to bat
alias bat="batcat"
#alias cat="batcat"

# fzf
# called from ~/scripts/
alias nlof='$HOME/scripts/fzf_listoldfiles.sh'
# opens documentation through fzf (eg: git,zsh etc.)
alias fman="compgen -c | fzf | xargs man"

# zoxide (called from ~/scripts/)
alias nzo='$HOME/scripts/zoxide_openfiles_nvim.sh'

# FastFetch alias
alias ff="fastfetch"

# alias for fzf-nova
alias fzf-nova="$HOME/.local/share/fzf-nova/fzf-nova"

# WSL: use SDK stored on Windows D: drive
if [ -d "/mnt/d/Android/Sdk" ]; then
  # Alias to run Android emulator with Windows paths (required for WSL)
  alias android-emulator='cd /mnt/d && ANDROID_SDK_ROOT="D:\Android\Sdk" ANDROID_HOME="D:\Android\Sdk" /mnt/d/Android/Sdk/emulator/emulator.exe'
fi

# Alias for cht.sh (cheat.sh)
alias cht="cht.sh --shell=bash --mode=auto --color=always"
