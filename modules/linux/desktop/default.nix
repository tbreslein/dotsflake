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
          # hyprland
          "hyprland"
          "hyprpolkitagent"
          "xdg-desktop-portal-hyprland"
          "wmenu"
          "hyprsunset"
          "wlogout"
          "hyprlock"
          "hyprpaper"
          "waybar"
          "mako"

          # wayland stuff
          "qt5-wayland"
          "qt6-wayland"
          "greetd"
          "egl-wayland"
          "xorg-xwayland"
          "wayland-protocols"
          "wl-clipboard"

          # general desktop apps
          "pavucontrol"
          "zathura"

          # fonts
          "noto-fonts"
          "noto-fonts-cjk"
          "noto-fonts-emoji"
          "noto-fonts-extra"
          "ttf-liberation"
          "ttf-roboto"

          # audio
          "pipewire"
          "pipewire-alsa"
          "pipewire-pulse"
          "pipewire-jack"
          "wireplumber"

          # codecs, misc., ...
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
          "alsa-lib"
          "alsa-plugins"
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
    };

    programs = {
      hyprlock = {
        enable = true;
        package = null;
        # TODO
      };
      hypridle = {
        enable = true;
        package = null;
        # TODO
      };
      hyprpaper = {
        enable = true;
        package = null;
        # TODO
      };
      hyprsunset = {
        enable = true;
        package = null;
        # TODO
      };
      waybar = {
        enable = true;
        package = pkgs-unstable.emptyDirectory;
        settings.mainBar = {
          layer = "top";
          position = "top";
          height = 40;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [ "pulseaudio" "battery" "cpu" "memory" "tray" "clock" ];
          "hyprland/window" = {
            format = " {} ";
            rewrite = {
              "(.*) - Zen Browser" = "Zen Browser";
            };
          };
          tray = {
            icon-size = 18;
            spacing = 15;
          };
          battery = {
            bat = "BAT0";
            states = {
              full = 99;
              good = 98;
              normal = 98;
              warning = 20;
              critical = 20;
            };
            format = "{icon}   {capacity}%";
            format-good = "{icon}   {capacity}%";
            format-full = "   {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            interval = 30;
          };
          network = {
            # interface = "wlp4s0";
            format-wifi = " ";
            format-disconnected = "睊";
            interval = 60;
          };
          pulseaudio = {
            format = "{icon}  {volume}%  ";
            format-bluetooth = "  {volume}%  ";
            format-muted = "婢  Mute  ";
            format-icons.default = [ "" ];
          };
          style = /* json */ ''
            * {
              font-family: "UbuntuMono Nerd Font";
              font-size: 16px;
            }

            window#waybar {
              background-color: #225877;
              color: #ffffff;
            }

            .modules-left {
            	background-color: #323232;
            	padding: 0px 0px 0px 0px;
            }

            .modules-right {
            	background-color: #323232;
            	padding: 0px 5px 0px 0px;
            }

            #custom-scratch {
            	background-color: #323232;
            	color: #b8b8b8;
            	padding: 0px 9px 0px 9px;
            }

            #workspaces {
            }

            #workspaces button {
            	padding: 0px 11px 0px 11px;
             	min-width: 1px;
            	color: #888888;
            }

            #workspaces button.focused {
            	padding: 0px 11px 0px 11px;
            	background-color: #285577;
            	color: #ffffff;
            }

            #mode {
            	background-color: #900000;
            	color: #ffffff;
              padding: 0px 5px 0px 5px;
              border: 1px solid #2f343a;
            }

            #window {
            	color: #ffffff;
            	background-color: #285577;
              padding: 0px 10px 0px 10px;
            }

            window#waybar.empty #window {
            	background-color: transparent;
            	color: transparent;
            }

            window#waybar.empty {
            	background-color: #323232;
            }

            #network, #temperature, #backlight, #pulseudio, #battery {
              padding: 0px 15px 0px 15px;
            }

            #clock {
            	margin: 0px 15px 0px 15px;
            }

            #tray {
              padding: 0px 8px 0px 5px;
              margin: 0px 5px 0px 5px;
            }

            #battery.critical {
              color: #ff5555;
            }
            #network.disconnected {
              color: #ff5555;
            }
          '';
        };

        wlogout = {
          enable = true;
          package = null;
          # TODO
        };

        imv.enable = true;
      };

      services = {
        mako = {
          enable = true;
          package = pkgs-unstable.emptyDirectory;
          # TODO
        };
      };
    };
  }
