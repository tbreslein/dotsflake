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
          "gst-plugin-pipewire"
        ] ++ lib.lists.concatMap (x: [ x ] ++ [ "lib32-${x}" ]) [
          "libva"
          "libva-mesa-driver"
          "gamemode"
          "mangohud"
          "vkd3d"
          "vulkan-icd-loader"

          "gst-libav"
          "gst-plugin-va"
          "gst-plugins-bad"
          "gst-plugins-bad-libs"
          "gst-plugins-base"
          "gst-plugins-base-libs"
          "gst-plugins-good"
          "gst-plugins-ugly"
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

          # "lib32-libva-mesa-driver"
          # "lib32-gamemode"
          # "lib32-mangohud"
          # "lib32-vkd3d"
          # "lib32-vulkan-icd-loader"
          # "lib32-libva"
          # "lib32-gst-plugins-base-libs"
          # "lib32-gst-plugins-good"
          # "lib32-alsa-lib"
          # "lib32-alsa-plugins"
          # "lib32-libpulse"
          # "lib32-giflib"
          # "lib32-libpng"
          # "lib32-libldap"
          # "lib32-gnutls"
          # "lib32-mpg123"
          # "lib32-openal"
          # "lib32-v4l-utils"
          # "lib32-libjpeg-turbo"
          # "lib32-libgpg-error"
          # "lib32-sqlite"
          # "lib32-libxcomposite"
          # "lib32-libxinerama"
          # "lib32-libgcrypt"
          # "lib32-ncurses"
          # "lib32-ocl-icd"
          # "lib32-libxslt"
          # "lib32-gtk3"
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
