_:

{
  myHome = {
    code = {
      enable = true;
    };
    linux = {
      enable = true;
      terminalFontSize = 17;
      extraWMEnv = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
    };
    syke = {
      pacman-pkgs = [
        #(syke should never touch these)
        # "base"
        # "base-devel"
        # "btrfs-progs"
        # "linux-lts"
        # "linux-firmware"
        # "cryptsetup"
        # "man-db"
        # "vim"
        # "networkmanager"
        # "openssh"
        # "pkgfile"
        # "reflector"
        # "sudo"
        # "zsh"
        # "efibootmgr"
        # "git"
        # "ufw"
        # "amd-ucode"

        #base
        "pacman-contrib"
        "syncthing"
        "gnutls"
        "gcc"

        #code
        "clang"
        "go"
        "cmake"
        "make"
        "ninja"
        "meson"

        #nvidia
        "linux-lts-headers"
        "nvidia-open-dkms"
        "nvidia-utils"
        "lib32-nvidia-utils"
        "nvidia-settings"

        #desktop
        "hyprland"
        "hyprpolkitagent"
        "xdg-desktop-portal-hyprland"
        "qt5-wayland"
        "qt6-wayland"
        "greetd"
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse"
        "pipewire-jack"
        "wireplumber"
        "egl-wayland"
        "xorg-xwayland"
        "wayland-protocols"
        "alacritty"
        "noto-fonts"
        "noto-fonts-cjk"
        "noto-fonts-emoji"
        "noto-fonts-extra"
        "ttf-liberation"
        "ttf-roboto"

        #gaming
        "steam"
        "steam-native-runtime"
        "gamescope"
        "alsa-lib"
        "alsa-plugins"
        "lib32-alsa-lib"
        "lib32-alsa-plugins"
        "libpulse"
        "lib32-libpulse"
        "gst-plugin-va"
        "gst-plugin-pipewire"
        "gst-plugins-bad"
        "gst-plugins-bad-libs"
        "gst-plugins-base"
        "gst-plugins-base-libs"
        "gst-plugins-good"
        "gst-plugins-ugly"
        "lib32-gst-plugins-base-libs"
        "lib32-gst-plugins-good"
        "libva"
        "lib32-libva"
        "libva-mesa-driver"
        "lib32-libva-mesa-driver"
        "gamemode"
        "goverlay"
        "mangohud"
        "lib32-mangohud"
        "vkd3d"
        "lib32-vkd3d"
        "vulkan-icd-loader"
        "lib32-vulkan-icd-loader"
        "opencl-icd-loader"
        "wine"
        "wine-gecko"
        "wine-mono"
        "wine-nine"
        "winetricks"
      ];

      aur-pkgs = [
        #base-aur
        "linux-cachyos"

        #nvidia
        "linux-cachyos-headers"

        #desktop
        "zen-browser-bin"

        #gaming
        "dxvk-bin"
        "proton-ge-custom-bin"
        "protontricks"
        "wine-installer"
      ];
    };
  };
}
