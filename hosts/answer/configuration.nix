{ pkgs-stable, pkgs-unstable, userConf, ... }:

{
  environment = {
    shells = [ pkgs-unstable.bashInteractive ];
    systemPackages = [ pkgs-unstable.localsend ];
    launchDaemons = {
      # TODO
    };
    userLaunchAgents = {
      # TODO
    };
  };

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = false;
    taps = [
      "gcc"
      "coreutils"
      "gnutls"
      "syncthing"
    ];
    casks = [
      "anki"
      "balenaetcher"
      "brave-browser"
      "ghostty"
    ];
  };

  launchd.agents = {
    # TODO
  };
  launchd.user.agents = {
    # TODO
  };

  networking = rec {
    hostName = "answer";
    computerName = hostName;
    localHostName = hostName;
  };

  nix = {
    enable = true;
    package = pkgs-stable.nix;
    optimise.automatic = true;
    settings.experimental-features = "nix-command flakes pipe-operators";
  };

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
    man.enable = true;
  };

  services = {
    aerospace = {
      # TODO
      # enable = true;
    };
    jankyborders = {
      # TODO
      # enable = true;
    };
    karabiner-elements = {
      # TODO
      # enable = true;
    };
    sketchybar = {
      # TODO
      # enable = true;
    };
  };

  system = {
    primaryUser = "${userConf.name}";
    defaults = {
      NSGlobalDomain = {
        NSAutomaticCapitalizationEnabled = false;
        "com.apple.keyboard.fnState" = false;
      };
      controlcenter = {
        AirDrop = false;
        BatteryShowPercentage = false;
        Bluetooth = false;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
        Sound = false;
      };
      dock = {
        autohide = true;
        launchanim = false;
        magnification = false;
        orientation = "bottom";
        persistent-apps = [
          { app = "/Applications/Spotify.app"; }
          { app = "/Applications/Zen Browser.app"; }
          { app = "/Applications/Ghostty.app"; }
          { app = "/Applications/Microsoft Teams.app"; }
          { app = "/Applications/Microsoft Outlook.app/"; }
          { app = "/Applications/1Password.app"; }
          { app = "/System/Applications/System Settings.app"; }
        ];
        show-recents = false;
        tilesize = 48;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = false;
      swapLeftCtrlAndFn = false;
    };
    startup.chime = false;
    stateVersion = 6;
  };
}
