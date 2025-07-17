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
    terminal = lib.mkOption {
      type = lib.types.enum [ "ghostty" "alacritty" "foot" ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      foot = {
        enable = cfg.terminal == "foot";
        font = "${userConf.monofont}:size=${cfg.terminalFontSize}";
        mouse.hide-when-typing = "yes";
        colors = {
          alpha = 0.95;
          inherit (userConf.colors.primary) background;
          inherit (userConf.colors.primary) foreground;
          regular0 = userConf.colors.normal.black;
          regular1 = userConf.colors.normal.red;
          regular2 = userConf.colors.normal.green;
          regular3 = userConf.colors.normal.yellow;
          regular4 = userConf.colors.normal.blue;
          regular5 = userConf.colors.normal.magenta;
          regular6 = userConf.colors.normal.cyan;
          regular7 = userConf.colors.normal.white;
          bright0 = userConf.colors.bright.black;
          bright1 = userConf.colors.bright.red;
          bright2 = userConf.colors.bright.green;
          bright3 = userConf.colors.bright.yellow;
          bright4 = userConf.colors.bright.blue;
          bright5 = userConf.colors.bright.magenta;
          bright6 = userConf.colors.bright.cyan;
          bright7 = userConf.colors.bright.white;
        };
      };
      ghostty = {
        enable = true;
        # enable = cfg.terminal == "ghostty";
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
        enable = cfg.terminal == "alacritty";
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
