{ config, lib, user-conf, ... }:

let
  cfg = config.my-system.aerospace;
in
{
  options.my-system.aerospace.enable = lib.mkEnableOption "Enable aerospace";

  config = lib.mkIf cfg.enable {
    services = {
      aerospace = {
        enable = true;
        settings = {
          # start-at-login = true;
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;
          default-root-container-layout = "tiles";
          default-root-container-orientation = "auto";
          on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
          automatically-unhide-macos-hidden-apps = true;
          key-mapping.preset = "qwerty";
          gaps = {
            inner = {
              horizontal = 0;
              vertical = 0;
            };
            outer = {
              left = 0;
              bottom = 0;
              top = 0;
              right = 0;
            };
          };
          mode = {
            main.binding = {
              alt-slash = "layout tiles horizontal vertical";
              alt-comma = "layout accordion horizontal vertical";

              cmd-h = "focus left";
              cmd-j = "focus down";
              cmd-k = "focus up";
              cmd-l = "focus right";
              cmd-ctrl-h = "move left";
              cmd-ctrl-j = "move down";
              cmd-ctrl-k = "move up";
              cmd-ctrl-l = "move right";
              cmd-alt-i = "resize smart -50";
              cmd-alt-o = "resize smart +50";
              cmd-t = "workspace 1";
              cmd-s = "workspace 2";
              cmd-r = "workspace 3";
              cmd-a = "workspace 4";
              cmd-g = "workspace 5";
              cmd-ctrl-t = "move-node-to-workspace 1";
              cmd-ctrl-s = "move-node-to-workspace 2";
              cmd-ctrl-r = "move-node-to-workspace 3";
              cmd-ctrl-a = "move-node-to-workspace 4";
              cmd-ctrl-g = "move-node-to-workspace 5";
              cmd-1 = "workspace 1";
              cmd-2 = "workspace 2";
              cmd-3 = "workspace 3";
              cmd-4 = "workspace 4";
              cmd-5 = "workspace 5";
              cmd-ctrl-1 = "move-node-to-workspace 1";
              cmd-ctrl-2 = "move-node-to-workspace 2";
              cmd-ctrl-3 = "move-node-to-workspace 3";
              cmd-ctrl-4 = "move-node-to-workspace 4";
              cmd-ctrl-5 = "move-node-to-workspace 5";
              cmd-ctrl-n = "move-node-to-monitor --wrap-around next";

              cmd-ctrl-f = "fullscreen";
              cmd-ctrl-semicolon = "mode service";
            };
            service.binding = {
              esc = [ "reload-config" "mode main" ];
              r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
              f = [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
              backspace = [ "close-all-windows-but-current" "mode main" ];

              # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
              # s = ["layout sticky tiling" "mode main"];

              alt-shift-h = [ "join-with left" "mode main" ];
              alt-shift-j = [ "join-with down" "mode main" ];
              alt-shift-k = [ "join-with up" "mode main" ];
              alt-shift-l = [ "join-with right" "mode main" ];
            };
          };
          on-window-detected = [
            {
              "if".app-id = "com.brave.Browser";
              run = "move-node-to-workspace 1";
            }
            {
              "if".app-id = "net.imput.helium";
              run = "move-node-to-workspace 1";
            }
            {
              "if".app-id = "org.alacritty";
              run = "move-node-to-workspace 2";
            }
            {
              "if".app-id = "com.mitchellh.ghostty";
              run = "move-node-to-workspace 2";
            }
            {
              "if".app-id = "com.microsoft.teams2";
              run = "move-node-to-workspace 3";
            }
            {
              "if".app-id = "com.microsoft.Outlook";
              run = "move-node-to-workspace 4";
            }
            {
              "if".app-id = "com.deezer.deezer-desktop";
              run = "move-node-to-workspace 5";
            }
            {
              "if".app-id = "com.apple.Music";
              run = "move-node-to-workspace 5";
            }
          ];
        };
      };
      jankyborders = {
        enable = true;
        active_color = "0xff${user-conf.colors.primary.border}";
        inactive_color = "0xff${user-conf.colors.normal.black}";
        width = 3.0;
      };
      karabiner-elements = {
        # enable = true;
      };
    };
  };
}
