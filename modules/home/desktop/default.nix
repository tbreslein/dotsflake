{ config, lib, userConf, pkgs-unstable, ... }:
let
  cfg = config.myHome.desktop;
in
{
  options.myHome.desktop = {
    enable = lib.mkEnableOption "Enable home desktop role";
    terminalFontSize = lib.mkOption {
      type = lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      ghostty = {
        enable = userConf.terminal == "ghostty";
        package =
          if config.myHome.linux.enable
          then pkgs-unstable.ghostty
          else null;
        enableBashIntegration = true;
        clearDefaultKeybinds = true;
        settings = {
          font-size = cfg.terminalFontSize;
          font-family = userConf.monofont;
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
            background = "#${userConf.colors.primary.background}";
            foreground = "#${userConf.colors.primary.foreground}";
            cursor-color = "#${userConf.colors.primary.foreground}";
            selection-background = "#${userConf.colors.bright.black}";
            selection-foreground = "#${userConf.colors.primary.foreground}";
            palette = [
              "0=#${userConf.colors.normal.black}"
              "1=#${userConf.colors.normal.red}"
              "2=#${userConf.colors.normal.green}"
              "3=#${userConf.colors.normal.yellow}"
              "4=#${userConf.colors.normal.blue}"
              "5=#${userConf.colors.normal.magenta}"
              "6=#${userConf.colors.normal.cyan}"
              "7=#${userConf.colors.normal.white}"
              "8=#${userConf.colors.bright.black}"
              "9=#${userConf.colors.bright.red}"
              "10=#${userConf.colors.bright.green}"
              "11=#${userConf.colors.bright.yellow}"
              "12=#${userConf.colors.bright.blue}"
              "13=#${userConf.colors.bright.magenta}"
              "14=#${userConf.colors.bright.cyan}"
              "15=#${userConf.colors.bright.white}"
            ];
          };
        };
      };
      alacritty = {
        # enable = userConf.terminal == "alacritty";
        enable = true;
        package =
          if config.myHome.linux.enable
          then pkgs-unstable.alacritty
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
            normal.family = userConf.monofont;
            size = cfg.terminalFontSize;
          };
          cursor.style.blinking = "Never";
          colors = rec {
            primary = {
              background = "0x${userConf.colors.primary.background}";
              foreground = "0x${userConf.colors.primary.foreground}";
            };
            normal = {
              black = "0x${userConf.colors.normal.black}";
              red = "0x${userConf.colors.normal.red}";
              green = "0x${userConf.colors.normal.green}";
              yellow = "0x${userConf.colors.normal.yellow}";
              blue = "0x${userConf.colors.normal.blue}";
              magenta = "0x${userConf.colors.normal.magenta}";
              cyan = "0x${userConf.colors.normal.cyan}";
              white = "0x${userConf.colors.normal.white}";
            };
            bright = normal;
          };
        };
      };

      tealdeer.enable = true;
    };
  };
}
