# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository using GNU Stow for deployment. Configurations support both macOS and Linux (Arch), with primary focus on terminal-based development workflow.

## Deployment

The repository uses GNU Stow to symlink configuration files to the home directory:

- **Stow target**: `~/` (configured in `.stowrc`)
- **Configuration source**: `home/` directory contains all dotfiles
- **Deploy configs**: `stow home` from repository root
- **Undeploy configs**: `stow -D home`

## Key Configuration Components

### Shell (Fish)
- **Config**: `home/.config/fish/config.fish`
- **Functions**: `home/.config/fish/functions/`
- Custom aliases use `eza` for enhanced `ls` functionality
- Key shortcuts:
  - `cfg` - Opens nvim in dotfiles directory
  - `dar` - Opens nvim in nix directory
  - `tvim` - Opens nvim in test mode
  - `dev` - Changes to development directory
- Development directory detection: `~/Development`, `~/development`, or `~/dev` stored in `$_dev`

### Neovim
- **Config root**: `home/.config/nvim/`
- **Entry point**: `init.lua` loads `smchunn.lazy`
- **Plugin manager**: lazy.nvim
- **Structure**:
  - `lua/smchunn/lazy.lua` - Lazy.nvim setup
  - `lua/smchunn/core/` - Core settings
  - `lua/smchunn/plugins/` - Plugin configurations
  - `lua/smchunn/workflows/` - Workflow configurations
  - `lua/smchunn/overrides/` - Local overrides
- **LSP Setup**:
  - Uses Mason for LSP server management
  - Configured servers: pyright, rust_analyzer, jinja_lsp, lua_ls
  - Completion: blink.cmp
  - Formatting: none-ls with stylua (Lua), black (Python), prettier (Markdown), alejandra (Nix)
  - Auto-format on save enabled
- **Test mode**: `test/init.lua` for plugin development

### Tmux
- **Config**: `home/.tmux.conf`
- **Prefix key**: `C-Space` (not default `C-b`)
- **Base index**: 1 (windows and panes)
- **Key features**:
  - Vi-mode keybindings
  - Mouse support enabled
  - Custom status bar (green session, blue active window)
  - Clipboard integration with wl-copy (Wayland)
  - Pane navigation with `Ctrl+Arrow` (no prefix)
  - Pane resizing with `Alt+Ctrl+Arrow`

### Terminal Emulators
- **Primary**: Alacritty (`home/.config/alacritty/alacritty.toml`)
  - Custom dark theme
  - Font: IosevkaTerm NFM Light, size 10
  - Extensive tmux integration via key bindings (Command key sends tmux sequences)
  - Auto-launches tmux with session management
- **Also configured**: Kitty, WezTerm

### Git
- **Config**: `home/.config/git/`
- **Global gitignore**: `home/.config/git/ignore`
- **Commit style**: Use Conventional Commits format
  - Format: `<type>(<scope>): <description>`
  - Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`, `perf`
  - Example: `feat(nvim): add obsidian plugin support`
  - Example: `fix(tmux): correct clipboard integration on wayland`
  - Example: `chore(fish): update surge prompt symbols`
- **Commit separation**: Follow separation of concerns
  - Each commit should address one logical change
  - Separate commits for different tools/components (nvim, fish, tmux, etc.)
  - Separate configuration changes from functional changes
  - When updating multiple tools, create separate commits per tool

## Window Management
- **macOS**: yabai (`home/.yabairc`), skhd, Hammerspoon, Amethyst
- **Linux**: Hyprland (`home/hypr/`), Waybar (`home/waybar/`)

## Editor Integrations
- **GitHub CLI**: `home/.config/gh/`
- **Helix**: `home/.config/helix/`
- **1Password**: `home/.config/1Password/`

## Workflow Notes

- Alacritty terminal starts Fish shell which auto-launches/attaches tmux sessions
- Tmux sessions are numbered (1, 2, 3...) and auto-managed on new terminal windows
- Neovim is the primary editor with full LSP support
- All formatting happens automatically on save via none-ls
- Custom Fish functions are used for common development tasks