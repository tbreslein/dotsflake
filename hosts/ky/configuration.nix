{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "ky";

  #boot.kernelPackages = pkgs.linuxPackages_cachyos;
  mySystem = {
    desktop.enable = true;
    amd.enable = true;
  };
}
