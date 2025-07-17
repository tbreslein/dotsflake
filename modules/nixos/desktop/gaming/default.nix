{ config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.nixos.desktop.gaming;
in
{
  options.my-system.nixos.desktop.gaming.enable = lib.mkEnableOption "enable my-system.nixos.desktop.gaming";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    users.users.${user-conf.name}.extraGroups = [ "games" "gamemode" ];

    environment.systemPackages = with pkgs; [
      mangohud
      protonup
      (lutris.override {
        extraLibraries = pkgs: [
          # List library dependencies here
        ];
        extraPkgs = pkgs: [
          wine-staging
          winetricks
          protontricks
        ];
      })
    ];

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
      gamemode.enable = true;
    };
  };
}
