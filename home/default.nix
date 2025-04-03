{ config, pkgs-stable, pkgs-unstable, inputs, ... }:
{
  home = {
    username = "tommy";
    homeDirectory = "/home/tommy";
    packages = with pkgs-unstable; [
      htop
    ];
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
