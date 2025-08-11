{ config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.alacritty;
in
{
  options.my-system.alacritty.enable = lib.mkEnableOption "Enable alacritty";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name}.programs.alacritty = {
      enable = true;
      package =
        if pkgs.stdenv.isLinux
        then pkgs.alacritty
        else null;
      settings = {
        window = {
          dynamic_padding = true;
          decorations = "None";
          opacity = 0.93;
          blur = true;
          option_as_alt = "Both";
        };
        font = {
          normal.family = user-conf.monofont;
          size = config.my-system.terminal-font-size;
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
  };
}
