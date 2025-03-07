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

function lg
  command eza -l --git $argv
end

function cfg
  command nvim -c "cd $HOME/dev/dotfiles/"
end

function dev
  command cd "$HOME/Development/"
end

function on
  command nvim -c "cd $VAULT" -c "autocmd User DashboardLoaded ObsidianNew $argv[1]"
end

function oo
  command nvim -c "cd $VAULT" -c "autocmd User DashboardLoaded ObsidianQuickSwitch"
end

pyenv init - | source


