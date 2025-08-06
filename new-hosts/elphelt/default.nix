{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # on rbpi, you cannot use grub or systemd-boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  my-system = {
    syncthing.enable-syncthing-server = true;
    bash.enable = true;
    git.enable = true;
    tmux.enable = true;
    nixos.enable-ssh-server = true;
  };

  home-manager.users.${user-conf.name}.home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
