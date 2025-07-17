{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "ky";
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  my-system.nixos = {
    enable = true;
    desktop.enable = true;
    amd.enable = true;
    laptop.enable = true;
  };
}
