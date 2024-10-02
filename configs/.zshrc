export PATH="/opt/homebrew/bin:/usr/local/sbin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="typewritten"

export TYPEWRITTEN_PROMPT_LAYOUT="singleline"
export TYPEWRITTEN_ARROW_SYMBOL="➜"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker k)

# export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

rvim() {
  local fp="${1:-.}"  # Use the provided directory or current directory if none is given
  fd -t f -H -E .git -E .DS_Store . "$fp" | fzf-tmux -p --reverse | xargs -I % nvim % -c "cd $fp"
}

vim() {
  local fp="${1:-.}"  # Use the provided directory or current directory if none is given
  fd -d 1 -t f -H -E .git -E .DS_Store . "$fp" | fzf-tmux -p --reverse | xargs -I % nvim % -c "cd $fp"
}

alias ka="k -a"
alias dev="cd $HOME/Development/"
alias dots="cd $HOME/Development/dotfiles"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# configs
cfg(){
  nvim -c "cd $HOME/Development/dotfiles/"
}

#obsidian
export VAULT="$HOME/Documents/vault/"

on() {
  nvim -c "cd $VAULT" -c "autocmd User DashboardLoaded ObsidianNew $*"
}

oo() {
  nvim -c "cd $VAULT" -c "autocmd User DashboardLoaded ObsidianQuickSwitch"
}

export AIRFLOW_HOME=~/Development/airflow
export VISUAL=nvim
export EDITOR="$VISUAL"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
