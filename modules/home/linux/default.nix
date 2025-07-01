{ config, lib, ... }:
let
  cfg = config.myHome.linux;
in
{
  imports = [
    ./desktop
    ./nvidia
  ];

  options.myHome.linux = {
    enable = lib.mkEnableOption "Enable home linux role";
  };

  config = lib.mkIf cfg.enable {
    services.syncthing.enable = true;
  };
}
