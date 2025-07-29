{ config, lib, user-conf, pkgs, ... }:
let
  cfg = config.my-home.desktop;

  # ghostty-start = pkgs.writeShellScriptBin "ghostty-start" /* bash */ ''
  #   SESSION_NAME="home"
  #   tmux has-session -t $SESSION_NAME 2>/dev/null
  #   if [ $? -eq 0 ]; then
  #     tmux attach-session -t $SESSION_NAME
  #   else
  #     tmux new-session -s $SESSION_NAME -d
  #     tmux attach-session -t $SESSION_NAME
  #   fi
  # '';
in
{
  options.my-home.desktop = {
    enable = lib.mkEnableOption "Enable home desktop role";
    terminal-font-size = lib.mkOption {
      type = lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables.TERMINAL = "ghostty";
      username = user-conf.name;
      packages = with pkgs; [
        nerd-fonts.commit-mono
        caligula
      ];
    };
    programs = {
      ghostty = {
        enable = true;
        package =
          if pkgs.stdenv.isLinux
          then pkgs.ghostty
          else null;
        enableBashIntegration = true;
        settings = {
          # command = "${ghostty-start}/bin/ghostty-start";
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
      tealdeer.enable = true;
    };
  };
}
