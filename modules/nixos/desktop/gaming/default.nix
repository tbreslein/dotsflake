{ config, lib, pkgs, userConf, ... }:
let
  cfg = config.mySystem.desktop.gaming;
in
{
  options.mySystem.desktop.gaming.enable = lib.mkEnableOption "enable nixos.desktop.gaming";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    users.users.${userConf.name}.extraGroups = [ "games" "gamemode" ];

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
