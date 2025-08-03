{ config, lib, pkgs, hm, user-conf, ... }:

let
  cfg = config.my-system.nixos.gaming;
in
{
  options.my-system.nixos.gaming = {
    enable = lib.mkEnableOption "Enable nixos.gaming";
  };

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

