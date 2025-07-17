{ config, lib, ... }:
let
  cfg = config.my-home.linux.nvidia;
in
{
  options.my-home.linux.nvidia.enable = lib.mkEnableOption "Enable home linux.nvidia role";

  config = lib.mkIf cfg.enable {
    my-home.linux.desktop.extra-wm-env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    ];
  };
}
