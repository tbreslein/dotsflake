{ config, lib, pkgs-stable, pkgs-unstable, userConf, ... }:

let
  appsSrc =
    config.system.build.applications + /Applications;

  baseDir =
    "/Applications/Nix Apps";

  copyScript =
    lib.optionalString (config ? system) ''
      echo 'Setting up /Applications/Nix Apps...' >&2
    ''
    + ''
      appsSrc="${appsSrc}"
      if [ -d "$appsSrc" ]; then
        baseDir="${baseDir}"
        rsyncFlags=(
          --archive
          --checksum
          --chmod=-w
          --copy-unsafe-links
          --delete
          --no-group
          --no-owner
        )
        $DRY_RUN_CMD mkdir -p "$baseDir"
        $DRY_RUN_CMD ${lib.getBin pkgs-stable.rsync}/bin/rsync \
          ''${VERBOSE_ARG:+-v} "''${rsyncFlags[@]}" "$appsSrc/" "$baseDir"
      fi
    '';
in

{
  system.activationScripts.applications.text = lib.mkForce copyScript;
  environment = {
    shells = with pkgs-unstable; [ bashInteractive ];
    systemPackages = with pkgs-unstable; [ bashInteractive localsend ];
    launchDaemons = {
      # TODO
    };
    userLaunchAgents = {
      # TODO
    };
  };

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    brews = [
      "gcc"
      { name = "syncthing"; restart_service = "changed"; }
    ];
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
      "homebrew/homebrew-bundle"
    ];
    casks = [
      "amethyst"
      "anki"
      "balenaetcher"
      "brave-browser"
      "ghostty"
    ];
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
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
