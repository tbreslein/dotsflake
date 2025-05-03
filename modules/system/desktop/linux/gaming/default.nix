{ config, lib, pkgs-stable, pkgs-unstable, ... }:

let
  cfg = config.mySystem.desktop.linux.gaming;
in
{
  imports = [
  ];

  options = {
    mySystem.desktop.linux.gaming.enable = lib.mkEnableOption "Enable system desktop linux gaming role";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = true;

      #  # Open ports in the firewall for Source Dedicated Server
      # dedicatedServer.openFirewall = true;
      #
      #  # Open ports in the firewall for Steam Local Network Game Transfers
      # localNetworkGameTransfers.openFirewall = true;
    };
  };
}
