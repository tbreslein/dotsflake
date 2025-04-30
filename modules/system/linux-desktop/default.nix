{ config, lib, pkgs-stable, pkgs-unstable, ... }:

let
  cfg = config.mySystem.linux-desktop;
in
{
  imports = [
  ];

  options = {
    mySystem.linux-desktop = {
      enable = lib.mkEnableOption "Enable system/linux-desktop role";
      extraUserPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "extra user-level packages to install on this host";
      };
      extraSystemPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "extra system-level packages to install on this host";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.tommy.packages = with pkgs-unstable; [
      brave
    ] ++ cfg.extraUserPackages;

    environment = {
      systemPackages = cfg.extraSystemPackages;
      # systemPackages = with pkgs-unstable; [
      # ] ++ cfg.extraSystemPackages;
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
    };

    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    };

    services = {
      xserver.xkb = {
        layout = "us";
        variant = "";
      };
      greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${pkgs-unstable.hyprland}/bin/hyprland";
            user = "tommy";
          };
          default_session = initial_session;
        };
      };
    };

  };
}
