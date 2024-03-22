export PATH="/opt/homebrew/bin:/usr/local/sbin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="typewritten"

export TYPEWRITTEN_PROMPT_LAYOUT="singleline"
export TYPEWRITTEN_ARROW_SYMBOL="➜"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker k)

# export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

alias rvim="fd -t f -H -E .git -E .DS_Store | fzf-tmux -p --reverse | xargs nvim"
alias vim="fd -d 1 -t f -H -E .git -E .DS_Store | fzf-tmux -p --reverse | xargs nvim"
alias ka="k -a"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export AIRFLOW_HOME=~/Development/airflow
export VISUAL=nvim
export EDITOR="$VISUAL"
