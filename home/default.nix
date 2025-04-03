{ config, pkgs-stable, pkgs-unstable, inputs, ... }:
{
  home = {
    username = "tommy";
    homeDirectory = "/home/tommy";
    packages = with pkgs-unstable; [
      nerd-fonts.hack
      # (nerdfonts.override { fonts = [ "Hack" ]; })
      htop
    ];
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  wayland.windowManager.river = {
    enable = true;
    xwayland.enable = true;
    settings = {
      map = {
        normal = {
          "Super Q" = "close";
          "Super Return" = "spawn foot";
          "Super Space" = "spawn fuzzel";
          "Super+Ctrl Q" = "exit";
          "Super J" = "focus-view next";
          "Super K" = "focus-view previous";
	};
      };
      spawn = [
        "waybar &"
      ];
      default-layout = "rivertile";
    };
    extraConfig = ''
      rivertile -view-padding 6 -outer-padding 6 &
    '';
  };
  programs = {
    fuzzel = {
      enable = true;
    };
    foot = {
      enable = true;
      settings = {
        main = {
	  font = "Hack Nerd Font:size=20";
	};
      };
    };
    waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
	position = "top";
	height = 30;
	modules-left = [ "river/tags" ];
	modules-center = [];
	modules-right = [ "pulseaudio" "battery" "cpu" "memory" "tray" "clock" ];
      };
    };
  };
}
