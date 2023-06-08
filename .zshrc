export PATH="$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="smchunn"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting tmux)

# export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

alias rvim="fd -t f -H -E .git -E .DS_Store | fzf-tmux -p --reverse | xargs nvim"
alias vim="fd -d 1 -t f -H -E .git -E .DS_Store | fzf-tmux -p --reverse | xargs nvim"
export PATH="/usr/local/sbin:$PATH"
