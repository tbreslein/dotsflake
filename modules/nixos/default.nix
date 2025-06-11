{ lib, pkgs, system, userConf, ... }: {
  imports = [
    ./amd
    ./nvidia
    ./desktop
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gnumake
  ];

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
    syncthing.openDefaultPorts = true;
    # openssh.enable = true;
  };

  users.users.${userConf.name} = {
    isNormalUser = true;
    description = "${userConf.name}";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = system;
  };
  system.stateVersion = "25.05";

  boot.loader = {
    timeout = 1;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Europe/Berlin";
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
}
