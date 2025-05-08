{ config, lib, pkgs-unstable, ... }:
let
  cfg = config.myHome.linux;
in
{
  options.myHome.linux = {
    enable = lib.mkEnableOption "Enable home desktop.linux role";
    terminalFontSize = lib.mkOption {
      type = lib.types.int;
    };
    extraWMEnv = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    targets.genericLinux.enable = true;

    home.packages = with pkgs-unstable; [
      wdisplays
      pamixer
      pavucontol
      playerctl
      brightnessctl
      grim
      slurp
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      settings = {
        "$mod" = "SUPER";
        exec = [
          # "wlsunset"
        ];
        monitor = ", highres@highrr, auto, 1";
        exec-once = [
          "waybar"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          # "blueman-applet"
          # "nm-applet"
          # "hyprpaper"
        ];
        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland"
          # "QT_STYLE_OVERRIDE,kvantum"
          # "QT_QPA_PLATFORMTHEME,qt6ct"
          # "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          # "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "MOZ_ENABLE_WAYLAND,1"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        ] ++ cfg.extraWMEnv;
        decoration = {
          rounding = 2;
        };
        general = {
          border_size = 1;
          col = {
            # active_border = "0xee${userSettings.colors.primary.accent}";
            # inactive_border = "0xee${userSettings.colors.bright.black}";
          };
          layout = "master";
        };
        input = {
          follow_mouse = 0;
          kb_layout = "us,de";
          # kb_options = "";
          repeat_delay = 300;
          repeat_rate = 35;
        };
        misc = {
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
          key_press_enables_dpms = true;
          mouse_move_enables_dpms = true;
        };
        windowrulev2 = [
          "float,title:^(Picture(.)in(.)picture)$"
          "pin,title:^(Picture(.)in(.)picture)$"
          # "float,class:^(steam)$,title:^(Friends list)$"
          # "float,class:^(steam)$,title:^(Steam Settings)$"
          # "workspace 3,class:^(steam)$"
          # "workspace 3,class:^(lutris)$"
          # "workspace 3,title:^(Wine System Tray)$"
          # "workspace 4,class:^(battle.net.exe)$"
        ];
        bind = [
          "$mod, Space, exec, fuzzel"
          "$mod, Return, exec, [workspace 2] foot"
          "$mod, b, exec, [workspace 1] zen"
          "$mod, q, killactive"
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
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod CTRL, 1, movetoworkspace, 1"
          "$mod CTRL, 2, movetoworkspace, 2"
          "$mod CTRL, 3, movetoworkspace, 3"
          "$mod CTRL, 4, movetoworkspace, 4"
          "$mod CTRL, 5, movetoworkspace, 5"
          "$mod, n, workspace, -1"
          "$mod, m, workspace, +1"
          "$mod CTRL, n, movetoworkspace, -1"
          "$mod CTRL, m, movetoworkspace, +1"

          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioLowerVolume, exec, pamixer -d 5"
          ", XF86AudioMute, exec, pamixer --toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"

          #     bind = $mod, p, exec, grim -g \"$(slurp)\" - | satty --filename - --copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
          #     bind = $mod ALT, p, exec, grim - | satty --filename - --copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
        ];
        bindel = [
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

    programs = {
      fuzzel = {
        enable = true;
        # package = null;
      };
      foot = {
        enable = true;
        # package = null;
        settings = {
          main = {
            font = "Hack Nerd Font:size=${toString cfg.terminalFontSize}";
          };
        };
      };
      waybar = {
        enable = true;
        # package = null;
        settings.mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ ];
          modules-right = [ "pulseaudio" "battery" "cpu" "memory" "tray" "clock" ];
        };
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

