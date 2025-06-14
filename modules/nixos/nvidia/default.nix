{ config, lib, ... }:
let
  cfg = config.mySystem.nvidia;
in
{
  options.mySystem.nvidia.enable = lib.mkEnableOption "enable nixos.nvidia";

  config = lib.mkIf cfg.enable {
    hardware = {
      graphics.enable = true;
      nvidia = {
        open = true;
        modesetting.enable = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
    };
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
