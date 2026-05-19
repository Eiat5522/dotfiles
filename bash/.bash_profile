if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

. "$HOME/.atuin/bin/env"
export PATH="/home/eiat/flutter/bin:$PATH"

. "$HOME/.local/bin/env"

# >>> spawn >>>
export PATH="/home/eiat/.bun/bin:$PATH"
# <<< spawn <<<

# Added by CodeRabbit CLI installer
export PATH="/home/eiat/.local/bin:$PATH"
