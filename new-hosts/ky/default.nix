{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  my-system = {
    ghostty.enable = false;
    alacritty.enable = false;
    foot.enable = true;
    terminal-font-size = 17;

    has-gui = true;
    kanata.enable = true;

    bash.enable = true;
    syncthing.enable-syncthing-client = true;

    git.enable = true;
    jujutsu.enable = true;

    code = {
      # emacs.enable = true;
      neovim = {
        enable = true;
        nvim-config = "minimal"; # or "big"
      };
      zed.enable = true;
    };
    tmux.enable = true;

    desktop = {
      enable = true;
      hypr.enable = true;
      laptop.enable = true;
      nvidia.enable = false;
      gaming.enable = false;
    };

    syke.enable = true;

    # aerospace.enable = true;
  };

  ${hm}.home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
