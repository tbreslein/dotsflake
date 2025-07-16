{ config, lib, pkgs-stable, pkgs-unstable, userConf, ... }:

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
      "node"
      { name = "syncthing"; restart_service = "changed"; }
    ];
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
      "homebrew/homebrew-bundle"
    ];
    casks = [
      "1password"
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
    man.enable = true;
  };

  services = {
    aerospace = {
      enable = false;
      settings = {
        start-at-login = true;
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        automatically-unhide-macos-hidden-apps = true;
        key-mapping.preset = "qwerty";
        gaps = {
          inner = {
            horizontal = 4;
            vertical = 4;
          };
          outer = {
            left = 2;
            bottom = 2;
            top = 2;
            right = 2;
          };
        };
        mode = {
          main.binding = {
            alt-slash = "layout tiles horizontal vertical";
            alt-comma = "layout accordion horizontal vertical";

            cmd-h = "focus left";
            cmd-j = "focus down";
            cmd-k = "focus up";
            cmd-l = "focus right";
            cmd-ctrl-h = "move left";
            cmd-ctrl-j = "move down";
            cmd-ctrl-k = "move up";
            cmd-ctrl-l = "move right";
            cmd-alt-i = "resize smart -50";
            cmd-alt-o = "resize smart +50";
            cmd-t = "workspace t";
            cmd-s = "workspace s";
            cmd-r = "workspace r";
            cmd-a = "workspace a";
            cmd-g = "workspace g";
            cmd-ctrl-t = "move-node-to-workspace t";
            cmd-ctrl-s = "move-node-to-workspace s";
            cmd-ctrl-r = "move-node-to-workspace r";
            cmd-ctrl-a = "move-node-to-workspace a";
            cmd-ctrl-g = "move-node-to-workspace g";
            cmd-tab = "workspace-back-and-forth";
            cmd-shift-tab = "move-workspace-to-monitor --wrap-around next";

            cmd-f = "fullscreen";
            cmd-ctrl-semicolon = "mode service";
          };
          service.binding = {
            esc = [ "reload-config" "mode main" ];
            r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
            f = [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
            backspace = [ "close-all-windows-but-current" "mode main" ];

            # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
            # s = ["layout sticky tiling" "mode main"];

            alt-shift-h = [ "join-with left" "mode main" ];
            alt-shift-j = [ "join-with down" "mode main" ];
            alt-shift-k = [ "join-with up" "mode main" ];
            alt-shift-l = [ "join-with right" "mode main" ];
          };
        };
        on-window-detected = [
          {
            "if".app-id = "com.brave.Browser";
            # if.app-id = 'com.brave.Browser'
            run = "move-node-to-workspace 1";
          }
          {
            "if".app-id = "app.zen-browser.zen";
            run = "move-node-to-workspace 1";
          }
          {
            "if".app-id = "app.zen-browser.zen";
            "if".window-title-regex-substring = "Picture-in-Picture";
            run = "layout floating";
          }
          {
            # "if".app-id = "org.alacritty";
            "if".app-id = "com.mitchellh.ghostty";
            run = "move-node-to-workspace 2";
          }
          {
            "if".app-id = "com.microsoft.teams2";
            run = "move-node-to-workspace 3";
          }
          {
            "if".app-id = "com.microsoft.Outlook";
            run = "move-node-to-workspace 4";
          }
        ];
      };
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
    activationScripts.applications.text = lib.mkForce copyScript;
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
