export ZSH="$HOME/.oh-my-zsh" 
[ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" 

ZSH_THEME="typewritten"

export TYPEWRITTEN_PROMPT_LAYOUT="singleline"
export TYPEWRITTEN_ARROW_SYMBOL="➜"
if [ -n "$SSH_CONNECTION" ]; then
  export TYPEWRITTEN_PROMPT_LAYOUT="singleline_verbose"
fi

plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker)

source $ZSH/oh-my-zsh.sh

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

source ~/.zshrc.os
