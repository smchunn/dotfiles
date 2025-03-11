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
    user = "smchunn";
    host = "mini";
    platform = "aarch64-darwin";
    iosevkaTerm = nixpkgs.legacyPackages.${platform}.iosevka.override {
      set = "Term";
    };
  in {
    darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
      system = platform;
      specialArgs = {inherit self iosevkaTerm user host platform;};
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = user;
          };
        }
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.extraSpecialArgs = {inherit user host;};
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import ./home.nix;
        }
      ];
    };
  };
}
