{ config, lib, userConf, ... }:
let
  cfg = config.myHome.linux;
in
{
  imports = [
    ./amd-cpu
    ./desktop
    ./gaming
    ./laptop
    ./nvidia
  ];

  options.myHome.linux = {
    enable = lib.mkEnableOption "Enable home linux role";
  };

  config = lib.mkIf cfg.enable {
    home.homeDirectory = "/home/${userConf.name}";

    myHome.syke = {
      systemd = {
        user-services-enabled = [
          "syncthing.service"
        ];
        services-enabled = [
          "systemd-timesyncd"
          "NetworkManager"
          "reflector.service"
          "reflector.timer"
          "paccache.timer"
        ];
      };
      arch = {
        pacman-pkgs = [
          #(syke should never touch these)
          # "base"
          # "base-devel"
          # "btrfs-progs"
          # "linux-lts"
          # "linux-firmware"
          # "cryptsetup"
          # "man-db"
          # "vim"
          # "networkmanager"
          # "openssh"
          # "pkgfile"
          # "reflector"
          # "sudo"
          # "zsh"
          # "efibootmgr"
          # "git"
          # "ufw"
          # "gcc"

          "pacman-contrib"
          "syncthing"
          "gnutls"
        ];
      };
    };
  };
}
