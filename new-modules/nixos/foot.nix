{ config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.nixos.foot;
in
{
  options.my-system.nixos.foot.enable = lib.mkEnableOption "Enable nixos.foot";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name}.programs.foot = {
      enable = true;
      settings = {
        main.font = "${user-conf.monofont}:size=${toString config.my-system.terminal-font-size}";
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
  };
}
