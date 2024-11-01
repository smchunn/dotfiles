export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="typewritten"

export TYPEWRITTEN_PROMPT_LAYOUT="singleline"
export TYPEWRITTEN_ARROW_SYMBOL="➜"
if [ -n "$SSH_CONNECTION" ]; then
  export TYPEWRITTEN_PROMPT_LAYOUT="singleline_verbose"
fi

plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker)

# export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

export VISUAL=nvim
export EDITOR="$VISUAL"

source .zshrc.os
