# smchunn's dotfiles

Configuration for macos. Includes git, neovim, alacritty, tmux, zsh, oh-my-zsh, hammerspoon, amethyst, and karabiner

xcode cli tools:
`xcode-select --install`

nix install:
`sh <(curl -L https://nixos.org/nix/install)`

nix-darwin install:
`nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/dev/dotfiles/configs/.config/nix#mini`

nix-darwin apply:
`darwin-rebuild switch --flake ~/dev/dotfiles/configs/.config/nix#mini`

## License

MIT / BSD
