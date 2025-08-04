{ config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.ghostty;
in
{
  options.my-system.ghostty.enable = lib.mkEnableOption "Enable ghostty";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name}.programs = {
      tmux = {
        terminal = "ghostty";
        extraConfig = ''
          set -sa terminal-overrides ",ghostty:RGB"
        '';
      };
      ghostty = {
        enable = true;
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
    };
  };
}
