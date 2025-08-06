{ pkgs, user-conf, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  my-system = {
    ghostty.enable = true;
    alacritty.enable = false;
    nixos.foot.enable = true;
    terminal = "foot";
    terminal-font-size = 17;

    has-gui = true;
    kanata.enable = false;

    bash.enable = true;
    syncthing.enable-syncthing-client = true;

    git.enable = true;
    jujutsu.enable = true;

    code = {
      # emacs.enable = true;
      neovim = {
        enable = true;
        nvim-config = "minimal";
      };
      zed.enable = true;
    };
    tmux.enable = true;

    nixos = {
      desktop.enable = true;
      hypr.enable = true;
      laptop.enable = false;
      nvidia.enable = true;
      gaming.enable = true;
    };

    syke.enable = true;

  };

  home-manager.users.${user-conf.name}.home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
