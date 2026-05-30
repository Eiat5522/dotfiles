# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

. "$HOME/.atuin/bin/env"

[ -f "/home/eiat/.ghcup/env" ] && . "/home/eiat/.ghcup/env" # ghcup-env
# >>> spawn >>>
export PATH="/home/eiat/.bun/bin:$PATH"
# <<< spawn <<<

# If bash reads ~/.profile directly, source ~/.bashrc only after login-time
# environment setup so interactive tools such as atuin are already on PATH.
if [ -n "$BASH_VERSION" ] && [ -z "${__BASH_PROFILE_SOURCED_PROFILE:-}" ]; then
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi


# Added by Antigravity CLI installer
export PATH="/home/eiat/.local/bin:$PATH"
