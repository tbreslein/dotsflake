{ config, lib, user-conf, pkgs, ... }:
let
  cfg = config.my-home.desktop;
in
{
  options.my-home.desktop = {
    enable = lib.mkEnableOption "Enable home desktop role";
    terminal-font-size = lib.mkOption {
      type = lib.types.int;
    };
    terminal = lib.mkOption {
      type = lib.types.enum [ "ghostty" "alacritty" "foot" ];
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.TERMINAL = "${cfg.terminal}";
    programs = {
      foot = {
        enable = cfg.terminal == "foot";
        settings = {
          main.font = "${user-conf.monofont}:size=${toString cfg.terminal-font-size}";
          mouse.hide-when-typing = "yes";
          colors = {
            alpha = 0.95;
            inherit (user-conf.colors.primary) background;
            inherit (user-conf.colors.primary) foreground;
            regular0 = user-conf.colors.normal.black;
            regular1 = user-conf.colors.normal.red;
            regular2 = user-conf.colors.normal.green;
            regular3 = user-conf.colors.normal.yellow;
            regular4 = user-conf.colors.normal.blue;
            regular5 = user-conf.colors.normal.magenta;
            regular6 = user-conf.colors.normal.cyan;
            regular7 = user-conf.colors.normal.white;
            bright0 = user-conf.colors.bright.black;
            bright1 = user-conf.colors.bright.red;
            bright2 = user-conf.colors.bright.green;
            bright3 = user-conf.colors.bright.yellow;
            bright4 = user-conf.colors.bright.blue;
            bright5 = user-conf.colors.bright.magenta;
            bright6 = user-conf.colors.bright.cyan;
            bright7 = user-conf.colors.bright.white;
          };
        };
      };
      ghostty = {
        enable = cfg.terminal == "ghostty";
        package =
          if pkgs.stdenv.isLinux
          then pkgs.ghostty
          else null;
        enableBashIntegration = true;
        settings = {
          font-size = cfg.terminal-font-size;
          font-family = user-conf.monofont;
          font-feature = "-calt, -liga, -dlig";
          theme = "_gruvbox-material";
          cursor-style = "block";
          cursor-style-blink = false;
          shell-integration-features = "no-cursor";
          mouse-hide-while-typing = true;
          background-opacity = 0.95;
          background-blur = true;
          window-padding-balance = true;
          window-decoration = "none";
          clipboard-read = "allow";
          clipboard-write = "allow";
          confirm-close-surface = false;
          quit-after-last-window-closed = true;
          macos-non-native-fullscreen = true;
          macos-titlebar-style = "hidden";
          macos-option-as-alt = true;
        };
        themes = {
          _gruvbox-material = {
            background = "#${user-conf.colors.primary.background}";
            foreground = "#${user-conf.colors.primary.foreground}";
            cursor-color = "#${user-conf.colors.primary.foreground}";
            selection-background = "#${user-conf.colors.bright.black}";
            selection-foreground = "#${user-conf.colors.primary.foreground}";
            palette = [
              "0=#${user-conf.colors.normal.black}"
              "1=#${user-conf.colors.normal.red}"
              "2=#${user-conf.colors.normal.green}"
              "3=#${user-conf.colors.normal.yellow}"
              "4=#${user-conf.colors.normal.blue}"
              "5=#${user-conf.colors.normal.magenta}"
              "6=#${user-conf.colors.normal.cyan}"
              "7=#${user-conf.colors.normal.white}"
              "8=#${user-conf.colors.bright.black}"
              "9=#${user-conf.colors.bright.red}"
              "10=#${user-conf.colors.bright.green}"
              "11=#${user-conf.colors.bright.yellow}"
              "12=#${user-conf.colors.bright.blue}"
              "13=#${user-conf.colors.bright.magenta}"
              "14=#${user-conf.colors.bright.cyan}"
              "15=#${user-conf.colors.bright.white}"
            ];
          };
        };
      };
      alacritty = {
        enable = cfg.terminal == "alacritty";
        package =
          if pkgs.stdenv.isLinux
          then pkgs.alacritty
          else null;
        settings = {
          window = {
            dynamic_padding = true;
            decorations = "None";
            opacity = 0.95;
            blur = true;
            option_as_alt = "Both";
          };
          font = {
            normal.family = user-conf.monofont;
            size = cfg.terminal-font-size;
          };
          cursor.style.blinking = "Never";
          colors = rec {
            primary = {
              background = "0x${user-conf.colors.primary.background}";
              foreground = "0x${user-conf.colors.primary.foreground}";
            };
            normal = {
              black = "0x${user-conf.colors.normal.black}";
              red = "0x${user-conf.colors.normal.red}";
              green = "0x${user-conf.colors.normal.green}";
              yellow = "0x${user-conf.colors.normal.yellow}";
              blue = "0x${user-conf.colors.normal.blue}";
              magenta = "0x${user-conf.colors.normal.magenta}";
              cyan = "0x${user-conf.colors.normal.cyan}";
              white = "0x${user-conf.colors.normal.white}";
            };
            bright = normal;
          };
        };
      };

      tealdeer.enable = true;
    };
  };
}
