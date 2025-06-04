{ config, lib, pkgs-unstable, ... }:
let
  cfg = config.myHome.linux.desktop;
in
{
  options.myHome.linux.desktop = {
    enable = lib.mkEnableOption "Enable home linux.desktop role";
    extraWMEnv = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs-unstable; [
        playerctl
        brightnessctl
        grim
        slurp
      ];
    };

    myHome.syke = {
      systemd.services-enabled = [
        "greetd"
        "bluetooth"
      ];
      arch = {
        pacman-pkgs = [
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
        ];
        aur-pkgs = [
          "zen-browser-bin"
        ];
      };
    };

    fonts.fontconfig.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      settings = {
        exec = [
          # "wlsunset"
        ];
        monitor = ", highres@highrr, auto, 1";
        exec-once = [
          "systemctl --user hyprpolkitagent"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "waybar &"
          # "blueman-applet"
          # "nm-applet"
          # "hyprpaper"
        ];
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland"
          # "QT_STYLE_OVERRIDE,kvantum"
          # "QT_QPA_PLATFORMTHEME,qt6ct"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "MOZ_ENABLE_WAYLAND,1"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
          "SDL_VIDEODRIVER,wayland"
          "_JAVA_AWT_WM_NONREPARENTING,1"
        ] ++ cfg.extraWMEnv;
        general = {
          border_size = 2;
          gaps_in = 5;
          gaps_out = 20;
          "col.active_border" = "rgba(33ccffee)";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "master";
        };
        animations.enabled = "no";
        input = {
          follow_mouse = 0;
          kb_layout = "us,de";
          # kb_options = "";
          repeat_delay = 300;
          repeat_rate = 35;
          touchpad.natural_scroll = false;
        };
        misc = {
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          key_press_enables_dpms = true;
          mouse_move_enables_dpms = true;
        };
        xwayland = {
          enabled = true;
          force_zero_scaling = true;
        };
        windowrulev2 = [
          "float,title:^(Picture(.)in(.)picture)$"
          "pin,title:^(Picture(.)in(.)picture)$"
          "float,class:^(steam)$,title:^(Friends list)$"
          "float,class:^(steam)$,title:^(Steam Settings)$"
          "workspace 3,class:^(steam)$"
        ];
        windowrule = [
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];
        "$mod" = "SUPER";
        bind = [
          "$mod, Space, exec, wmenu-run -i -f \"Hack Nerd Font Normal 24\""
          "$mod, Return, exec, [workspace 2] alacritty"
          "$mod, b, exec, [workspace 1] zen-browser"
          "$mod CTRL, q, killactive"
          "$mod ALT, q, exit"
          "$mod, f, fullscreen, 1"
          "$mod ALT, f, fullscreen, 0"
          "$mod ALT, v, togglefloating,"

          "$mod, h, movefocus, l"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod, l, movefocus, r"
          "$mod CTRL, h, swapwindow, l"
          "$mod CTRL, j, swapwindow, d"
          "$mod CTRL, k, swapwindow, u"
          "$mod CTRL, l, swapwindow, r"
          "$mod ALT, h, resizeactive, -10,0"
          "$mod ALT, j, resizeactive, 0,10"
          "$mod ALT, k, resizeactive, 0,-10"
          "$mod ALT, l, resizeactive, 10,0"
          "$mod, Tab, cyclenext,"
          "$mod, Tab, bringactivetotop,"
          "$mod, s, workspace, 1"
          "$mod, t, workspace, 2"
          "$mod, r, workspace, 3"
          "$mod, n, workspace, 4"
          "$mod CTRL, s, movetoworkspace, 1"
          "$mod CTRL, t, movetoworkspace, 2"
          "$mod CTRL, r, movetoworkspace, 3"
          "$mod CTRL, n, movetoworkspace, 4"
          "$mod, b, workspace, -1"
          "$mod, w, workspace, +1"
          "$mod CTRL, b, movetoworkspace, -1"
          "$mod CTRL, w, movetoworkspace, +1"

          #     bind = $mod, p, exec, grim -g \"$(slurp)\" - | satty --filename - --copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
          #     bind = $mod ALT, p, exec, grim - | satty --filename - --copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
        ];
        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
      #   /*
      #   hyprlang
      #   */
      #   ''
      #     monitor = ${config.myConf.wayland.extraHyprlandConf.monitor}
      #     monitor = ,preferred,auto,1
      #   '';
      #
      # ".config/waybar/config.jsonc".text =
      #   /*
      #   json
      #   */
      #   ''
      #     {
      #       "layer": "top",
      #       "position": "top",
      #       "modules-left": ["hyprland/workspaces", "hyprland/window"],
      #       "modules-center": ["clock"],
      #       "modules-right": ["pulseaudio", "battery", "tray"],
      #       "hyprland/window": {
      #         "format": "{}",
      #         "rewrite": {
      #           "(.*) - Brave": "Brave"
      #         },
      #         "separate-outputs": true
      #       },
      #       "tray": {
      #         "icon-size": 18,
      #         "spacing": 15
      #       },
      #       "clock": {
      #         "format": "{:%R}",
      #         "interval": 30
      #       },
      #       "battery": {
      #         "bat": "BAT0",
      #         "states": {
      #           "full": 90,
      #           "good": 70,
      #           "normal": 50,
      #           "warning": 30,
      #           "critical": 15,
      #           "format": "{icon}   {capacity}%",
      #           "format-good": "{icon}   {capacity}%",
      #           "format-full": "   {capacity}%",
      #           "format-icons": ["", "", "", "", ""],
      #           "interval": 30
      #         },
      #       },
      #       "pulseaudio": {
      #         "format": "{icon}  {volume}%  ",
      #         "format-bluetooth": "  {volume}%  ",
      #         "format-muted": "婢  Mute  ",
      #         "interval": 60,
      #         "format-icons": {
      #           "default": [""],
      #         }
      #       }
      #     }

    };

    programs.waybar = {
      enable = true;
      package = pkgs-unstable.emptyDirectory;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ ];
        modules-right = [ "pulseaudio" "battery" "cpu" "memory" "tray" "clock" ];
      };
    };

    services = {
      mako = {
        enable = true;
        # package = null;
      };
    };
  };
}
