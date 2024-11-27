{
  description = "Simple Nix-Darwin system with NixOS and Homebrew integration";

inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
    }:
    let
      hostPlatform = "aarch64-darwin";
      configuration = { pkgs, ... }: {
      services.nix-daemon.enable = true;

      nixpkgs.hostPlatform = hostPlatform;

      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;

      users.users.smchunn = {
        name = "smchunn";
        home = "/Users/smchunn";
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        neovim
        tmux
        htop
        curl
        fd
        fzf
        git
        lazygit
        ripgrep
        nodejs
        rustup
      ];
      fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "Meslo" ]; })
      ];
      homebrew = {
        enable = true;
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
        onActivation.cleanup = "zap";

        taps = [];
        brews = [];
        casks = [
          "firefox"
          "alfred"
          "alacritty"
          "1password"
          "1password-cli"
          "obsidian"
          "amethyst"
          "steermouse"
          "microsoft-outlook"
          "microsoft-excel"
          "microsoft-word"
        ];
      };

      system.defaults = {
        dock = {
          autohide = true;
          tilesize = 34;
          expose-animation-duration = 0.15;
          show-recents = false;
          persistent-apps = [
            "/System/Applications/Launchpad.app/"
            "/Applications/Firefox.app"
            "/System/Cryptexes/App/System/Applications/Safari.app"
            "/System/Applications/System Settings.app/"
            "/System/Applications/App Store.app/"
            "/Applications/Microsoft Outlook.app"
            "/Applications/Microsoft Excel.app"
            "/Applications/Microsoft Word.app"
            "/System/Applications/Preview.app/"
            "/Applications/Obsidian.app"
            "/Applications/Alacritty.app"
            "/Applications/1password.app"
          ];
        };
        NSGlobalDomain = {
          NSNavPanelExpandedStateForSaveMode = true;
          PMPrintingExpandedStateForPrint = true;
          NSDocumentSaveNewDocumentsToCloud = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          InitialKeyRepeat = 20;
          KeyRepeat = 1;
          NSAutomaticSpellingCorrectionEnabled = false;
          AppleShowAllExtensions = true;
          ApplePressAndHoldEnabled = false;
          "com.apple.springing.enabled" = true;
          "com.apple.springing.delay" = 0.1;
        };
        trackpad = {
          FirstClickThreshold = 0;
          ActuationStrength = 0;
        };
        finder = {
          NewWindowTarget = "Home";
          ShowStatusBar = true;
          _FXShowPosixPathInTitle = false;
          FXDefaultSearchScope = "SCcf";
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          # QLEnableTextSelection = true;
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
        };
        screencapture = {
          location = "~/Downloads";
          type = "png";
          disable-shadow = true;
        };
        # universalaccess.reduceTransparency = true;
      };

      system.stateVersion = 5;
    };
  in
    {
      darwinConfigurations."mini" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
        ];
      };
    };
}
