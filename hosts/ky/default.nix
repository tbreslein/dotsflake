{ pkgs, user-conf, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  my-system = {
    ghostty.enable = false;
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

    tmux.enable = true;
    code = {
      enable = true;
      # emacs.enable = true;
      neovim.enable = true;
      neovim.nvim-config = "minimal";
      zed.enable = true;
    };

    nixos = {
      desktop.enable = true;
      hypr.enable = true;
      laptop.enable = true;
      nvidia.enable = false;
      gaming.enable = false;
    };

    syke.enable = true;
  };

  home-manager.users.${user-conf.name}.home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
