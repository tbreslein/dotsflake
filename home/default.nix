{ config, pkgs-stable, pkgs-unstable, inputs, ... }:
{
  home = {
    username = "tommy";
    homeDirectory = "/home/tommy";
    packages = with pkgs-unstable; [
      htop
      foot
    ];
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  wayland.windowManager.river = {
    enable = true;
    # package = pkgs-unstable.river;
    xwayland.enable = true;
    settings = {
      map = {
        "Super Q" = "close";
        "Super Return" = "spawn foot";
        "Super+Ctrl Q" = "exit";
        "Super J" = "focus-view next";
        "Super K" = "focus-view previous";
      };
      spawn = [
        "waybar &"
      ];
    };
  };
  programs = {
    waybar = {
      enable = true;
      package = pkgs-unstable.waybar;
    };
  };
}
