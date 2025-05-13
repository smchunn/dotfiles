status is-interactive || return
# Commands to run in interactive sessions can go here
set fish_greeting

set fish_color_command magenta
set --global surge_symbol_git_branch ' '
set --global surge_symbol_git_ahead ' '
set --global surge_symbol_git_behind ' '

test -d "$HOME/Development" && set -g _dev "$HOME/Development"
test -d "$HOME/development" && set -g _dev "$HOME/development"
test -d "$HOME/dev" && set -g _dev "$HOME/dev"
if type -q eza
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
end

function cfg
  command nvim -c "cd $_dev/dotfiles"
end

function tvim
  command nvim -c "cd $_dev/dotfiles" -u "$HOME/.config/nvim/test/init.lua"
end

function dev
  command cd "$_dev"
end

function on
  # command nvim -c "cd $OBSIDIAN_VAULT" -c "autocmd User DashboardLoaded ObsidianNew $argv[1]"
  new_note $argv
  command hx -w $VAULT $VAULT
end

function oo
  # command nvim -c "cd $OBSIDIAN_VAULT" -c "autocmd User DashboardLoaded ObsidianQuickSwitch"
  # command nvim -c "cd $OBSIDIAN_VAULT"
  command hx -w $VAULT $VAULT
end

pyenv init - | source

set fish_path (string join ":" $PATH)
if grep -q "export PATH=" ~/.zshrc
    sed -i '' "s|export PATH=.*|export PATH=\"$fish_path\"|" ~/.zshrc
else
    echo "export PATH=\"$fish_path\"" >> ~/.zshrc
end
