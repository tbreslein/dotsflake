{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # on rbpi, you cannot use grub or systemd-boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "elphelt";
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    wget
    tree
    vim
    git
  ];

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # doesn't work with flakes
  #system.copySystemConfiguration = true;

  system.stateVersion = "25.05";
}

