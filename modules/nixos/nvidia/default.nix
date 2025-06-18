{ config, lib, ... }:
let
  cfg = config.mySystem.nvidia;
in
{
  options.mySystem.nvidia.enable = lib.mkEnableOption "enable nixos.nvidia";

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.kernelModules = [ "nvidia" "nvidia_uvm" "nvidia_drm" ];
      extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    };

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
