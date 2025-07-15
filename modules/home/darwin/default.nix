{ config
, lib
  # , pkgs-stable
, ...
}:
let
  cfg = config.myHome.darwin;
in
{
  options = {
    myHome.darwin = {
      enable = lib.mkEnableOption "Enable home darwin";
    };
  };

  config = lib.mkIf cfg.enable { };
}
