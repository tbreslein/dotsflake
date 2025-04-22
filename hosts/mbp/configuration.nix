{ config, pkgs, ... }:

{
  environment.systemPackages =
    with pkgs; [
      localsend
    ];

  nix = {
    enable = false;
    package = pkgs.nix;
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };

  # # Create /etc/zshrc that loads the nix-darwin environment.
  # programs = {
  #   gnupg.agent.enable = true;
  #   zsh.enable = true;  # default shell on catalina
  # };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # # Install fonts
  # fonts.fontDir.enable = true;
  # fonts.fonts = [
  #   pkgs.monaspace
  # ];

  # # Use homebrew to install casks and Mac App Store apps
  # homebrew = {
  #   enable = true;
  #
  #   casks = [
  #     "1password"
  #     "bartender"
  #     "brave-browser"
  #     "fantastical"
  #     "firefox"
  #     "hammerspoon"
  #     "karabiner-elements"
  #     "obsidian"
  #     "raycast"
  #     "soundsource"
  #     "wezterm"
  #   ];
  #
  #   masApps = {
  #     "Drafts" = 1435957248;
  #     "Reeder" = 1529448980;
  #     "Things" = 904280696;
  #     "Timery" = 1425368544;
  #   };
  # };
  #
  # # set some OSX preferences that I always end up hunting down and changing.
  # system.defaults = {
  #   # minimal dock
  #   dock = {
  #     autohide = true;
  #     orientation = "left";
  #     show-process-indicators = false;
  #     show-recents = false;
  #     static-only = true;
  #   };
  #   # a finder that tells me what I want to know and lets me work
  #   finder = {
  #     AppleShowAllExtensions = true;
  #     ShowPathbar = true;
  #     FXEnableExtensionChangeWarning = false;
  #   };
  #   # Tab between form controls and F-row that behaves as F1-F12
  #   NSGlobalDomain = {
  #     AppleKeyboardUIMode = 3;
  #     "com.apple.keyboard.fnState" = true;
  #   };
  # };
}
