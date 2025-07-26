{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # on rbpi, you cannot use grub or systemd-boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.wireless.enable = false;
  #networking.firewall.allowedTCPPorts = [ 22 ];

  my-system.nixos = {
    enable = true;
    enable-ssh-server = true;
  };
}
