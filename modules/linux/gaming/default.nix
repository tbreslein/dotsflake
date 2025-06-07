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
          "goverlay"
          "opencl-icd-loader"
          "wine-staging"
          "wine-gecko"
          "wine-mono"
          "wine-nine"
          "winetricks"
          "lact"
        ] ++ lib.lists.concatMap (x: [ x ] ++ [ "lib32-${x}" ]) [
          "libva"
          "libva-mesa-driver"
          "gamemode"
          "mangohud"
          "vkd3d"
          "vulkan-icd-loader"

          "alsa-lib"
          "alsa-plugins"
          "pipewire-jack"
          "libpulse"
          "giflib"
          "libpng"
          "libldap"
          "gnutls"
          "mpg123"
          "openal"
          "v4l-utils"
          "libgpg-error"
          "libjpeg-turbo"
          "sqlite"
          "libxcomposite"
          "libxinerama"
          "libgcrypt"
          "ncurses"
          "ocl-icd"
          "libxslt"
          "gtk3"
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
