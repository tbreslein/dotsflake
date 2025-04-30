{ config, pkgs-stable, pkgs-unstable, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.initrd.luks.devices."luks-8b57d86d-a385-48d2-b393-ba1cc1e9fdd0".device = "/dev/disk/by-uuid/8b57d86d-a385-48d2-b393-ba1cc1e9fdd0";

  networking.hostName = "raziel";

  config.mySystem = {
    linux-desktop.enable = true;
    gaming.enable = false;
  };
}
