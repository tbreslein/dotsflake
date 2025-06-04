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
      # get theme names from: https://github.com/alacritty/alacritty-theme
      # theme = "gruvbox_material_hard_dark";
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
          # normal.family = "DepartureMono Nerd Font";
          size = cfg.terminalFontSize;
        };
        cursor.style.blinking = "Never";
      };
    };
  };
}
