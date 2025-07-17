{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.wireless.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  my-system.nixos = {
    enable = true;
    desktop.enable = true;
    desktop.gaming.enable = true;
    amd.enable = true;
    nvidia.enable = true;
  };
}
