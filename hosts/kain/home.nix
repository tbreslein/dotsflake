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
      services = [
        #base
        "systemd-timesyncd"

        #desktop
        "bluetooth"
      ];
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
        "waybar"
        "wl-clipboard"
        "pavucontrol"
        "wmenu"
        "wlsunset"
        "hyprpaper"
        "xf86-input-synaptics"
        "xf86-input-libinput"
        "xf86-input-evdev"
        "bluez"
        "bluez-utils"
        "gst-libav"
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
        "alsa-lib"
        "alsa-plugins"
        "lib32-alsa-lib"
        "lib32-alsa-plugins"
        "libpulse"
        "lib32-libpulse"
        "giflib"
        "lib32-giflib"
        "libpng"
        "lib32-libpng"
        "libldap"
        "lib32-libldap"
        "gnutls"
        "lib32-gnutls"
        "mpg123"
        "lib32-mpg123"
        "openal"
        "lib32-openal"
        "v4l-utils"
        "lib32-v4l-utils"
        "libgpg-error"
        "lib32-libgpg-error"
        "libjpeg-turbo"
        "lib32-libjpeg-turbo"
        "sqlite"
        "lib32-sqlite"
        "libxcomposite"
        "lib32-libxcomposite"
        "libxinerama"
        "lib32-libxinerama"
        "libgcrypt"
        "lib32-libgcrypt"
        "ncurses"
        "lib32-ncurses"
        "ocl-icd"
        "lib32-ocl-icd"
        "libxslt"
        "lib32-libxslt"
        "gtk3"
        "lib32-gtk3"

        #gaming
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

        #laptop
        "tlp"
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
        "faudio"
        "lib32-faudio"
      ];
    };
  };
}
