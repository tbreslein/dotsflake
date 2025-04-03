# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs-stable, pkgs-unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    initrd.luks.devices."luks-8b57d86d-a385-48d2-b393-ba1cc1e9fdd0".device = "/dev/disk/by-uuid/8b57d86d-a385-48d2-b393-ba1cc1e9fdd0";
  };

  networking = {
    hostName = "raziel";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };


  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.tommy = {
    isNormalUser = true;
    description = "tommy";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs-unstable; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs-unstable; [
    vim
    git
    neovim
    gnumake
  ];

  programs = {
    river = {
      enable = true;
      package = pkgs-unstable.river;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "24.11";
}
