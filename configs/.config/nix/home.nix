# home.nix
{
  config,
  pkgs,
  ...
}: {
  # Define your user
  home.username = "smchunn";
  home.homeDirectory = "/Users/smchunn";

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    bat
  ];

  # programs.fish = {
  #   enable = true;
  #   shellInit = ''
  #     set -gx EDITOR hx
  #   '';
  #   shellAliases = {
  #     ll = "eza -la";
  #     cat = "bat";
  #   };
  # };
  # home.file.".config/helix/languages.toml".source = ./configs/helix/languages.toml;
}
