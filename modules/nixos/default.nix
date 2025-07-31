{ config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.nixos;
  priv-group = "wheel";
in
{
  imports = [
    ./amd
    ./nvidia
    ./desktop
    ./laptop
  ];
  options.my-system.nixos = {
    enable = lib.mkEnableOption "enable my-system.nixos";
    enable-ssh-server = lib.mkEnableOption "enable openssh server";
    enable-syncthing-server = lib.mkEnableOption "enable syncthing server";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vim
      wget
      git
      gnumake
      tmux
      ccrypt
      gnutar
      htop
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
      # syncthing = { openDefaultPorts = true; } // (
      #   if cfg.enable-syncthing-server
      #   then user-conf.syncthing-config
      #   else { }
      # );

      openssh = {
        enable = cfg.enable-ssh-server;
        openFirewall = true;
        settings = {
          PasswordAuthentication = true;
          AllowUsers = [ user-conf.name ];
          PermitRootLogin = "no";
        };
      };
    };

    users.users.${user-conf.name} = {
      isNormalUser = true;
      description = "${user-conf.name}";
      extraGroups = [ "networkmanager" priv-group ];
      openssh.authorizedKeys.keys =
        if cfg.enable-ssh-server then
          [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcPzu/AuetrxltYxJYeFuB8JHmw6418B5dBIlXPTVuJ6DX16javeZX3H18xzQd4oGjfo9veRLw9658eo8AZkrRj7ab+RzA41K8gzb3Iz8oAvmQgNrCbUSBrYvVKTSeSTIxT6qYvP9oszlxoLFjZEBoTRaVqHupG8LaOOO3/AckyPw0aVHY0NlglN/02n9SIJptSNGEkqGt5qYQuTK/z1wVIBsD6OhiYEPMaQ7mOWHjkQ3OsVspzeR1YuI4DUCe1RS5ebofnGbzqDeIxIkuysTJsQ/O/KTzaNYHDS08wsDOraQR9pEKnW85rMy5C4lvAuFrBUHPaiJwoMVg7+XIvykR1W45b2BD5sgb+9S05GQdHUXYdEPvJULAZCTfP0A6bC7NX/Gu1AtXi0yklpFE/joG3oJmzdRr1WxjHAbtrniGu78jS3ifNZcoMHhxhemwXOUoCzPM10tyPA4UHZpBZJuTQuTP+Tw0XsUUUxx1xjuR3Gkh3wncZcIzReNb0V/vL8+letPGoeXQ6nbEzCpTFa9FwRpMpcG788iDPoLQzuRZhb/FAmUZE1sUya+8QaynZZcSs3V5o5LSL1I0aibYImwDxJUhJ0bpyiNizkzAiuUQkbukEybmdsf8km7JlbmDrKV3SzcopkFwyy30Q1sMjuwfnzFtdld0YX3xEufokHTe+w== tommy@Tommys-MBP.fritz.box"

            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDt85YgZtE7KngfTa/iVP8KYzh8Xo1IfEC6tmBfMZ8yIduCsL7UaP6Ifvmg6HZv94RRa9pWMKhVtiSabpHwYqU71JoIm+oCaEs276gwbf76sSocKRKUmHqFlHzkCahVIww/zZzvh2e40jDWr4LfzcZPpRKIB3eX/GsWwoGRLBbYim9h0EccN3mnzgVwT2MQ5SLhtpJbguW0QORpG2BeUEyPPpactqwKlxxORxH2G9YbXLl+QVCjgslcb4d2MSrQcTTuwfFjexYmUHAPkHKv0Uo2feunytEs+lFFAv9+hGy3bWsaSyxy0U9oHdlQt5ag3hnjGsXNqAyeFir6+zlNByJkGKPUk3H/zEzARnh2WNtKbeQ8hW0lWgFTyldU+39oEsNnV1mLCUlwFSTQhfx97UZXws7qw9vTM8F128qWVZ1VHvZn0hnIMvSA+e0OGQYBrR1Ik2qiDgGPLUHHoI+QPvu6feKkCxJ3BGD42DK8KoJIW5BJjf1Kb9eGAdDWkqc5Xu2RSbvzO4HbrLJnWlpzLDGylg5g/+JqiPyMj2e1H6cz8zA8X/hf2vctnTfrjg0DMYDAmnKL05BJET+mQAoJfVCnJD8n+Pg225ikONMrdvZBFy3mJbupEF2TXgsUCyz5ZooZpIU7ekxc49XthpeahRxEjJOKBXaom4EvF4TptUcKtw== tommy.breslein@protonmail.com"
          ]
        else [ ];
    };

    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "25.05";

    networking =
      let
        mk-etc-hosts = hosts: with lib.attrsets;
          mapAttrs' (name: value: nameValuePair value.ip [ name ]) hosts;
      in
      {
        useDHCP = lib.mkDefault true;
        networkmanager.enable = true;
        firewall.enable = true;
        hostName = user-conf.hostname;
        hosts = mk-etc-hosts user-conf.hosts;
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
