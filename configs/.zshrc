export PATH="$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:/usr/local/sbin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(git zsh-autosuggestions zsh-syntax-highlighting tmux)

# export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

fpath+=$HOME/.zsh/typewritten
autoload -U promptinit; promptinit
prompt typewritten

alias rvim="fd -t f -H -E .git -E .DS_Store | fzf-tmux -p --reverse | xargs nvim"
alias vim="fd -d 1 -t f -H -E .git -E .DS_Store | fzf-tmux -p --reverse | xargs nvim"
