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
      alacritty = {
        enable = userConf.terminal == "alacritty";
        package =
          if config.home.myHome.linux.enable
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
