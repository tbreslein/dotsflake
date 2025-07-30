{ mk-syncthing-config, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # on rbpi, you cannot use grub or systemd-boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  networking.wireless.enable = false;
  my-system.nixos = {
    enable = true;
    enable-ssh-server = true;
    enable-syncthing-server = false;
  };

  services.syncthing = (mk-syncthing-config config lib hostname user-conf "/home/${user-conf.name}/sync");
}
