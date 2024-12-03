status is-interactive || return
# Commands to run in interactive sessions can go here
set fish_greeting

set -x VAULT "$HOME/Documents/vault/"

function ls
  command eza $argv
end

function la
  command eza -la $argv
end

function ll
  command eza -l $argv
end

function cfg
  command /opt/homebrew/bin/nvim -c "cd $HOME/Development/dotfiles/"
end

function dev
  command cd "$HOME/Development/"
end

function on
  /opt/homebrew/bin/nvim -c "cd $VAULT" -c "autocmd User DashboardLoaded ObsidianNew $argv[1]"
end

function oo
  /opt/homebrew/bin/nvim -c "cd $VAULT" -c "autocmd User DashboardLoaded ObsidianQuickSwitch"
end

eval "$(/opt/homebrew/bin/brew shellenv)"
pyenv init - | source



