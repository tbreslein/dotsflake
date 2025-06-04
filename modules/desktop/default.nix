{ config, lib, ... }:
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
    myHome.syke.arch.pacman-pkgs = [
      "alacritty"
    ];

    programs.alacritty = {
      enable = true;
      package = null;
      settings = {
        window = {
          dynamic_padding = true;
          decorations = "None";
          opacity = 0.95;
          blur = true;
          option_as_alt = "Both";
        };
        font = {
          normal.family = "Terminess Nerd Font";
          # normal.family = "Hack Nerd Font";
          size = cfg.terminalFontSize;
        };
        cursor.style.blinking = "Never";
        colors = rec {
          primary = {
            background = "0x1d2021";
            foreground = "0xd4be98";
          };
          normal = {
            black = "0x32302f";
            red = "0xea6962";
            green = "0xa9b665";
            yellow = "0xd8a657";
            blue = "0x7daea3";
            magenta = "0xd3869b";
            cyan = "0x89b482";
            white = "0xd4be98";
          };
          bright = normal;
        };
      };
    };
  };
}
