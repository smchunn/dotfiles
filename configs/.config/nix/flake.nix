# flake.nix
{
  description = "Simple Nix-Darwin system with NixOS and Homebrew integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
  }: let
    hostPlatform = "aarch64-darwin";
    iosevkaTerm = nixpkgs.legacyPackages.${hostPlatform}.iosevka.override {
      set = "Term";
    };
  in {
    darwinConfigurations."mini" = nix-darwin.lib.darwinSystem {
      system = hostPlatform; # Pass system explicitly
      specialArgs = {inherit self iosevkaTerm;}; # Pass self and iosevkaTerm to modules
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "smchunn";
          };
        }
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.smchunn = import ./home.nix;
        }
      ];
    };
  };
}
