status is-interactive || return
# Commands to run in interactive sessions can go here
set fish_greeting

if not type -q fisher
    echo "Installing fisher..."
    curl -sL https://git.io/fisher | source
    fisher install jorgebucaran/fisher
end

set plugin "smchunn/surge.fish"
if not contains -- $plugin (fisher list)
    echo "Installing $plugin..."
    fisher install $plugin
end

set fish_color_command magenta
set --global surge_symbol_git_branch ''
set --global surge_symbol_git_ahead ''
set --global surge_symbol_git_behind ''
set --global surge_fetch true

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

function dar
  command nvim -c "cd $_dev/nix"
end

function tvim
  command nvim -c "cd $_dev/dotfiles/home/.config/nvim" -u "$HOME/.config/nvim/test/init.lua"
end

function svim
  command sudo -E HOME="$HOME" nvim $argv
end

function dev
  command cd "$_dev"
end

function note
  command nvim -c "cd $OBSIDIAN_VAULT" -c "Obsidian quick_switch"
end

pyenv init - | source

# set fish_path (string join ":" $PATH)
# if grep -q "export PATH=" ~/.zshrc
#     sed -i '' "s|export PATH=.*|export PATH=\"$fish_path\"|" ~/.zshrc
# else
#     echo "export PATH=\"$fish_path\"" >> ~/.zshrc
# end

alias claude="/Users/smchunn/.claude/local/claude"
