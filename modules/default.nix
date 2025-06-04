{ pkgs-unstable, ... }:

{
  imports = [
    ./code
    ./linux
    ./syke
    ./desktop
  ];

  nix.gc.automatic = true;

  home = {
    username = "tommy";
    packages = with pkgs-unstable; [
      nerd-fonts.hack
      nerd-fonts.departure-mono
      htop

      fzf
      ripgrep
      fd
      bat
      lazygit
      gitu

      nh
    ];
    stateVersion = "24.11";

    file.".config/nix/nix.conf".text = ''
      experimental-features = nix-command flakes pipe-operators
    '';
  };

  programs.home-manager.enable = true;
}
