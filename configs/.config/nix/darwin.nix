# darwin.nix
{config, pkgs, IosevkaTerm, ...}: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  # nixpkgs.hostPlatform = hostPlatform;

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 5;
  system.configurationRevision = self.rev or self.dirtyRev or null;

  programs.fish.enable = true;
  environment.shells = [pkgs.fish];

  users.users.smchunn = {
    name = "smchunn";
    home = "/Users/smchunn";
    shell = pkgs.fish;
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
    eza
    fish
    pyenv
    helix
    rust-analyzer
    alejandra
    prettierd
    black
  ];
  fonts = {
    packages = with pkgs; [
      nerd-fonts.meslo-lg
      iosevkaTerm
    ];
  };
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";

    taps = [
      "nikitabobko/tap"
    ];
    brews = [];
    casks = [
      "firefox"
      "alfred"
      "alacritty"
      "1password"
      "1password-cli"
      "obsidian"
      "nikitabobko/tap/aerospace"
      "steermouse"
      "microsoft-outlook"
      "microsoft-excel"
      "microsoft-word"
      "jump"
      "jump-desktop-connect"
      "dropbox"
      "betterdisplay"
      "wezterm"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Things 3" = 904280696;
    };
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
        "/Applications/WezTerm.app"
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

};
