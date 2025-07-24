{ config, lib, pkgs, system, user-conf, hostname, ... }:
let
  cfg = config.my-system.nixos;
in
{
  imports = [
    ./amd
    ./nvidia
    ./desktop
    ./laptop
  ];
  options.my-system.nixos.enable = lib.mkEnableOption "enable my-system.nixos";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vim
      wget
      git
      gnumake
    ];
    nix = {
      settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
      gc.automatic = true;
      gc.dates = "weekly";
    };

    services = {
      xserver.xkb = {
        layout = "us";
        variant = "";
      };
      syncthing.openDefaultPorts = true;
      # openssh.enable = true;
    };

    users.users.${user-conf.name} = {
      isNormalUser = true;
      description = "${user-conf.name}";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    nixpkgs = {
      config.allowUnfree = true;
      hostPlatform = system;
    };
    system.stateVersion = "25.05";

    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      loader = {
        timeout = 1;
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
      };
    };

    networking = {
      useDHCP = lib.mkDefault true;
      networkmanager.enable = true;
      firewall.enable = true;
      hostName = hostname;
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
  };
}
