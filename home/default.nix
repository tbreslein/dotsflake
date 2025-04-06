{ config, pkgs-stable, pkgs-unstable, inputs, ... }:
{
  home = {
    username = "tommy";
    homeDirectory = "/home/tommy";
    packages = with pkgs-unstable; [
      nerd-fonts.hack
      htop

      wlr-randr
      wdisplays
      pamixer
      playerctl
      brightnessctl

      fzf
      ripgrep
      fd
      lazygit

      stylua
      lua-language-server
      bash-language-server
      nixd
      statix
      nixpkgs-fmt
    ];
    stateVersion = "24.11";
    file."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotsflake/nvim";
      target = ".config/nvim";
    };
  };

  programs.home-manager.enable = true;

  wayland.windowManager.river = {
    enable = true;
    xwayland.enable = true;
    settings = {
      border-color-focused = "0x93a1a1";
      border-color-unfocused = "0x586e75";
      border-width = 2;
      rule-add = {
        "-title" = {
          "'Picture in picture'" = "float";
        };
      };
      set-repeat = "50 300";
      map = {
        normal = {
          "Super Q" = "close";
          "Super Return" = "spawn foot";
          "Super Space" = "spawn fuzzel";
          "Super+Control Q" = "exit";
          "Super J" = "focus-view next";
          "Super K" = "focus-view previous";
          "Super+Control J" = "swap next";
          "Super+Control K" = "swap previous";
          "Super+Control F" = "toggle-fullscreen";
          "Super+Control V" = "toggle-float";
          "Super 1" = "set-focused-tags 1";
          "Super 2" = "set-focused-tags 2";
          "Super 3" = "set-focused-tags 3";
          "Super 4" = "set-focused-tags 4";
          "Super 5" = "set-focused-tags 5";
          "Super+Control 1" = "set-view-tags 1";
          "Super+Control 2" = "set-view-tags 2";
          "Super+Control 3" = "set-view-tags 3";
          "Super+Control 4" = "set-view-tags 4";
          "Super+Control 5" = "set-view-tags 5";
          "Super BTN_LEFT" = "move-view";
          "Super BTN_RIGHT" = "resize-view";
          "Super BTN_MIDDLE" = "toggle-float";
          "None XF86AudioRaiseVolume" = "spawn 'pamixer -i 5'";
          "None XF86AudioLowerVolume" = "spawn 'pamixer -d 5'";
          "None XF86AudioMute" = "spawn 'pamixer --toggle'";
          "None XF86AudioPlay" = "spawn 'playerctl play-pause'";
          "None XF86AudioPrev" = "spawn 'playerctl previous'";
          "None XF86AudioNext" = "spawn 'playerctl next'";
          "None XF86MonBrightnessUp" = "spawn 'brightnessctl set +5%'";
          "None XF86MonBrightnessDown" = "spawn 'brightnessctl set +5%-'";
        };
      };
      spawn = [
        "waybar &"
      ];
      default-layout = "rivertile";
    };
    extraSessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      XDG_CURRENT_DESKTOP = "wlroots";
      # QT_QPA_PLATFORMTHEME = "qt6ct";
    };
    extraConfig = ''
      wlr-randr --output eDP-1 --mode 2880x1920@120Hz --scale 2
      rivertile -view-padding 6 -outer-padding 6 &
    '';
  };
  programs = {
    fuzzel = {
      enable = true;
    };
    foot = {
      enable = true;
      settings = {
        main = {
          font = "Hack Nerd Font:size=14";
        };
      };
    };
    waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "river/tags" ];
        modules-center = [ ];
        modules-right = [ "pulseaudio" "battery" "cpu" "memory" "tray" "clock" ];
      };
    };
  };

  services = {
    mako = {
      enable = true;
    };
    syncthing.enable = true;
  };
}
