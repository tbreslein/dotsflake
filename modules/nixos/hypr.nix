{ config, lib, pkgs, user-conf, ... }:

let
  cfg = config.my-system.nixos.hypr;
in
{
  options.my-system.nixos.hypr = {
    enable = lib.mkEnableOption "Enable nixos.hypr";
  };

  config = lib.mkIf cfg.enable {
    # to hypr
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      NIXOS_OZONE_WL = "1";
    };
    services.greetd = {
      enable = true;
      settings =
        let
          session = "${pkgs.hyprland}/bin/Hyprland";
          tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
        in
        {
          initial_session = {
            command = session;
            user = user-conf.name;
          };
          default_session = {
            # run tuigreet, when quitting the initial_session
            command = "${tuigreet} --asterisks --remember --remember-user-session --time --cmd ${session}";
            user = "greeter";
          };
        };
    };

    home-manager.users.${user-conf.name} = {
      home = {
        packages = with pkgs; [
          playerctl
          brightnessctl
          grim
          slurp
          wmenu
          wl-clipboard
          nwg-look
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          noto-fonts-monochrome-emoji
          pavucontrol
        ];
      };

      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          exec = [
          ];
          monitor = ", highres@highrr, auto, 1.5";
          exec-once = [
            "wl-paste --type text --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
            "waybar &"
            # "blueman-applet"
          ];
          env = [
            "XCURSOR_THEME,Capitaine Cursors"
            "XCURSOR_SIZE,34"
            "HYPRCURSOR_THEME,Capitaine Cursors"
            "HYPRCURSOR_SIZE,34"
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
          ] ++ (
            if config.my-system.nixos.nvidia.enable
            then [
              "LIBVA_DRIVER_NAME,nvidia"
              "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            ]
            else [ ]
          );
          general = {
            border_size = 2;
            gaps_in = 5;
            gaps_out = 20;
            "col.active_border" = "rgba(${user-conf.colors.primary.border}ee)";
            "col.inactive_border" = "rgba(${user-conf.colors.primary.background}aa)";
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
            "float,title:^([pP]icture(.)in(.)[pP]icture)$"
            "pin,title:^([pP]icture(.)in(.)[pP]icture)$"
            "float,class:^(steam)$,title:^(Friends list)$"
            "float,class:^(steam)$,title:^(Steam Settings)$"
            "workspace 3,class:^(steam)$"
          ];
          windowrule = [
            "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
          ];
          "$mod" = "SUPER";
          bind = [
            ''
              $mod, Space, exec, wmenu-run -i -f \
                "${user-conf.monofont} Normal \
                ${builtins.toString config.my-system.terminal-font-size}" \
                -N ${user-conf.colors.primary.background} \
                -n ${user-conf.colors.primary.foreground} \
                -S ${user-conf.colors.normal.black} \
                -s ${user-conf.colors.primary.accent} \
            ''
            "$mod, Return, exec, [workspace 2] ${config.my-system.terminal}"
            "$mod, b, exec, [workspace 1] brave"
            "$mod ALT, n, exec, makoctl dismiss -a"
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
            "$mod, t, workspace, 1"
            "$mod, s, workspace, 2"
            "$mod, r, workspace, 3"
            "$mod, a, workspace, 4"
            "$mod, g, workspace, 5"
            "$mod CTRL, t, movetoworkspace, 1"
            "$mod CTRL, s, movetoworkspace, 2"
            "$mod CTRL, r, movetoworkspace, 3"
            "$mod CTRL, a, movetoworkspace, 4"
            "$mod CTRL, g, movetoworkspace, 4"
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
          settings = {
            general = {
              disable_loading_bar = true;
              grace = 3;
              hide_cursor = true;
              no_fade_in = false;
            };

            background = [
              {
                path = "screenshot";
                blur_passes = 3;
                blur_size = 8;
              }
            ];

            input-field = [
              {
                size = "50%, 5%";
                position = "0, -80";
                monitor = "";
                dots_center = true;
                fade_on_empty = false;
                font_color = "rgba(${user-conf.colors.primary.foreground}ee)";
                inner_color = "rgba(${user-conf.colors.normal.black}ee)";
                check_color = "rgba(${user-conf.colors.primary.accent}ee)";
                fail_color = "rgba(${user-conf.colors.primary.error}ee)";
                outline_thickness = 0;
                rounding = 0;
                font_family = "${user-conf.monofont}";
                placeholder_text = "Password ... ";
                shadow_passes = 2;
              }
            ];
            label = [
              {
                font_size = 120;
                font_family = "Noto Font Bold";
                font_color = "rgba(${user-conf.colors.primary.foreground}ee)";
                text = "$TIME";
                position = "-30, 0";
                halign = "center";
                valign = "top";
              }
              {
                font_size = 60;
                font_family = "Noto Font";
                font_color = "rgba(${user-conf.colors.primary.foreground}ee)";
                text = "cmd[update:60000] date +\"%A, %d %B %Y\""; # update every 60 seconds
                position = "-30, -150";
                halign = "center";
                valign = "top";
              }
            ];
          };
        };
        waybar = {
          enable = true;
          settings.mainBar = {
            layer = "top";
            position = "top";
            height = 30;
            modules-left = [ "hyprland/workspaces" "hyprland/window" ];
            modules-center = [ ];
            modules-right = [ "pulseaudio" "battery" "tray" "clock" ];
            "hyprland/window".format = " {} ";
            tray = {
              icon-size = 18;
              spacing = 15;
            };
            battery = {
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
              format-wifi = " ";
              format-disconnected = "睊";
              interval = 60;
            };
            wireplumber = {
              format = "{icon}  {volume}%  ";
              format-bluetooth = "  {volume}%  ";
              format-muted = "婢  Mute  ";
              format-icons.default = [ "" ];
              on-click = "wpctl set-volume @DEFAULT_AUDIO_SINK@ toggle";
              on-click-right = "pavucontrol";
            };
          };
          style = /* css */ ''
            * {
              font-family: "${user-conf.monofont}";
              font-size: ${builtins.toString config.my-system.terminal-font-size}px;
            }

            window#waybar {
              background-color: #${user-conf.colors.primary.background};
              color: #${user-conf.colors.primary.foreground};
            }

            .modules-left {
            	padding: 0px 0px 0px 0px;
            }

            .modules-right {
            	padding: 0px 5px 0px 0px;
            }

            #workspaces {
            }

            #workspaces button {
            	padding: 0px 11px 0px 11px;
             	min-width: 1px;
            	color: #${user-conf.colors.primary.foreground};
            }

            #workspaces button.active {
            	padding: 0px 11px 0px 11px;
            	color: #${user-conf.colors.primary.accent};
            }

            #window {
              padding: 0px 10px 0px 20px;
            }

            window#waybar.empty #window {
            	background-color: transparent;
            	color: transparent;
            }

            window#waybar.empty {
            	background-color: #${user-conf.colors.normal.black};
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
              color: #${user-conf.colors.primary.error};
            }
            #network.disconnected {
              color: #${user-conf.colors.primary.error};
            }
          '';
        };
      };

      services = {
        hypridle = {
          enable = true;
          settings = {
            general = {
              after_sleep_cmd = "hyprctl dispatch dpms on";
              ignore_dbus_inhibit = false;
              lock_cmd = "hyprlock";
            };

            listener = [
              {
                timeout = 900;
                on-timeout = "hyprlock";
              }
              {
                timeout = 1200;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
            ];
          };
        };
        mako = {
          enable = true;
          settings = {
            actions = true;
            anchor = "top-right";
            background-color = "#${user-conf.colors.primary.background}";
            border-color = "#${user-conf.colors.primary.border}";
            border-radius = 0;
            default-timeout = 0;
            font = "Noto Font ${builtins.toString (config.my-system.terminal-font-size - 5)}";
            height = 1000;
            width = 500;
            icons = true;
            ignore-timeout = false;
            layer = "top";
            margin = 10;
            markup = true;
          };
        };
        wlsunset = {
          enable = true;
          sunrise = "07:00";
          sunset = "18:00";
        };

        hyprpolkitagent.enable = true;
        swww.enable = true;
      };
    };
  };
}
