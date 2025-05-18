{ config
, lib
, pkgs-unstable
, ...
}:
let
  cfg = config.myHome.syke;
in
{
  options = {
    myHome.syke = {
      enable = lib.mkEnableOption "Enable syke";
      pacman-pkgs = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
      aur-pkgs = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable { };
}
