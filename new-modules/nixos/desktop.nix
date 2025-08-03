{ config, lib, pkgs, hm, user-conf, ... }:

let
  cfg = config.my-system.nixos.desktop;
in
{
  options.my-system.nixos.desktop = {
    enable = lib.mkEnableOption "Enable nixos.desktop";
  };

  config = lib.mkIf cfg.enable {
    # NOTE: these cannot be used on raspberry pis
    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      loader = {
        timeout = 1;
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      brave
      kdePackages.breeze-gtk
      kdePackages.breeze-icons
      capitaine-cursors
    ];
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    ${hm}.fonts.fontconfig.enable = true;
  };
}
