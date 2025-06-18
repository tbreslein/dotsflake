{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    wireless.enable = false;
    hostName = "sol";
  };

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  mySystem = {
    desktop.enable = true;
    desktop.gaming.enable = true;
    amd.enable = true;
    nvidia.enable = true;
  };
}
