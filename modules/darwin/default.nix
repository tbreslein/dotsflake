{ config, lib, pkgs, user-conf, ... }:

let
  appsSrc = config.system.build.applications + /Applications;
  baseDir = "/Applications/Nix Apps";
  copyScript = ''
    echo 'Setting up /Applications/Nix Apps...' >&2
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
  imports = [
    ../common
    ./aerospace
  ];

  environment = {
    shells = with pkgs; [ bashInteractive ];
    systemPackages = with pkgs; [ bashInteractive localsend ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.man.enable = true;

  home-manager.users.${user-conf.name}.programs.bash.profileExtra = /* bash */ ''
    [[ -f "/opt/homebrew/bin/brew" ]] && \
      eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  homebrew = {
    enable = true;
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
      "homebrew/homebrew-bundle"
    ];
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
  };

  networking = rec {
    hostName = user-conf.hostname;
    computerName = hostName;
    localHostName = hostName;
  };

  nix = {
    enable = true;
    package = pkgs-stable.nix;
    optimise.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    gc.automatic = true;
    gc.dates = "weekly";
  };

  system = {
    activationScripts.applications.text = lib.mkForce copyScript;
    primaryUser = "${user-conf.name}";
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
          { app = "/Applications/Brave Browser.app"; }
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
