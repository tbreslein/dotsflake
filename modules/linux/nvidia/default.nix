{ config, lib, ... }:
let
  cfg = config.myHome.linux.nvidia;
in
{
  options.myHome.linux.nvidia.enable = lib.mkEnableOption "Enable home linux.nvidia role";

  config = lib.mkIf cfg.enable {
    myHome = {
      linux.desktop.extraWMEnv = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
      syke.arch = {
        pacman-pkgs = [
          "linux-lts-headers"
          "nvidia-open-dkms"
          "nvidia-utils"
          "lib32-nvidia-utils"
          "nvidia-settings"
        ];
      };
    };
  };
}
