{ config, lib, ... }:
let
  cfg = config.myHome.linux.gaming;
in
{
  options.myHome.linux.gaming.enable = lib.mkEnableOption "Enable home linux.gaming role";

  config = lib.mkIf cfg.enable {
    myHome.syke = {
      systemd.services-enabled = [
        "lactd"
      ];
      arch = {
        pacman-pkgs = [
          "steam"
          "steam-native-runtime"
          "lutris"
          "gamescope"
          "libva"
          "lib32-libva"
          "libva-mesa-driver"
          "lib32-libva-mesa-driver"
          "gamemode"
          "lib32-gamemode"
          "goverlay"
          "mangohud"
          "lib32-mangohud"
          "vkd3d"
          "lib32-vkd3d"
          "vulkan-icd-loader"
          "lib32-vulkan-icd-loader"
          "opencl-icd-loader"
          "wine-staging"
          "wine-gecko"
          "wine-mono"
          "wine-nine"
          "winetricks"
          "lact"
        ];
        aur-pkgs = [
          "dxvk-bin"
          "proton-ge-custom-bin"
          "protontricks"
          "wine-installer"
          "faudio"
          "lib32-faudio"
        ];
      };
    };
  };
}
