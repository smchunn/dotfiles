status is-interactive || return
# Commands to run in interactive sessions can go here
set fish_greeting

set fish_color_command magenta
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
  command nvim -c "cd $HOME/dev/nix"
end

function tvim
  command nvim -c "cd $HOME/dev/nix" -u "$HOME/.config/nvim/test/init.lua"
end

function dev
  command cd "$HOME/Development/"
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
