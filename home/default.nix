{ config, pkgs-stable, pkgs-unstable, inputs, ... }:

let
  tmux-sessionizer = pkgs-unstable.writeShellScriptBin "tmux-sessionizer" /* bash */ ''
    folders=("''\$HOME")
    add_dir() {
      [ -d "''\$HOME/''\$1" ] && folders+=("''\$HOME/''\$1")
    }
    add_dir "code"
    add_dir "repos"

    if [[ ''\$# -eq 1 ]]; then
      selected=''\$1
    else
      selected=''\$(find ''\$(echo "''\${folders[@]}") -mindepth 1 -maxdepth 1 -type d | fzf)
    fi

    if [[ -z ''\$selected ]]; then
      exit 0
    fi

    selected_name=''\$(basename "''\$selected" | tr . _)
    tmux_running=''\$(pgrep tmux)

    if [[ -z ''\$TMUX ]] && [[ -z ''\$tmux_running ]]; then
      tmux new-session -s "''\$selected_name" -c "''\$selected"
      exit 0
    fi

    if ! tmux has-session -t="''\$selected_name" 2>/dev/null; then
      tmux new-session -ds "''\$selected_name" -c "''\$selected"
    fi

    tmux switch-client -t "''\$selected_name"
  '';

  git-status = pkgs-unstable.writeShellScriptBin "git-status" /* bash */ ''
    if git rev-parse >/dev/null 2>&1; then
        result=" ''\$(git rev-parse --abbrev-ref HEAD) "
        if [ ''\$(git status --porcelain=v1 | wc -l) -gt 0 ]; then
            result="''\${result}!"
        fi
        status_uno=''\$(git status -uno)
        if echo "''\$status_uno" | grep -q "Your branch is behind"; then
            result="''\${result}"
        fi
        if echo "''\$status_uno" | grep -q "Your branch is ahead"; then
            result="''\${result}"
        fi
        if echo "''\$status_uno" | grep -q "Your branch and '.*' have diverged"; then
            result="''\${result}"
        fi
        echo "''\$result"
    else
        echo ""
    fi
  '';
in
{
  nix = {
    settings.extra-experimental-features = [ "nix-command" "flakes" ];
    gc.automatic = true;
  };
  # launchd = {
  #   enable = true;
  #   agents.moco.config = {
  #     ProgramArguments = [ "${pkgs-stable.poetry}" "run" "python" "moco_client.py" ];
  #     WorkingDirectory = "${config.home.homeDirectory}/work/repos/mocotrackingclient";
  #   };
  # };
  home = {
    username = "tommy";
    homeDirectory = "/home/tommy";
    packages = with pkgs-unstable; [
      nerd-fonts.hack
      htop

      wdisplays
      pamixer
      playerctl
      brightnessctl
      grim
      slurp
      wl-clipboard

      fzf
      ripgrep
      fd
      lazygit
      bat
      tmux-sessionizer
      git-status
    ];
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  programs.bat.enable = true;

  programs.tmux = {
    enable = true;
    escapeTime = 0;
    historyLimit = 25000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-Space";
    extraConfig =
      /*
        tmux
      */
      ''
        set -g default-terminal "foot"
        set -sa terminal-overrides ",foot:RGB"

        bind-key -r C-f run-shell "tmux new-window ${tmux-sessionizer}"
        bind-key C-g new-window -n lazygit -c "#{pane_current_path}" "lazygit"
        bind-key C-o command-prompt -p "open app: " "new-window '%%'"

        bind-key C-s split-pane
        bind-key C-v split-pane -h

        set -g status-interval 2
        set -g status-style "fg=colour3 bg=colour0"
        set -g status-left-length 200
        set -g status-right-length 300
        set -g status-left "#S "
        set -g status-right "#(cd #{pane_current_path}; ${git-status})"
        set -g status-justify absolute-center

        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?\.?(view|n?vim?x?)(-wrapped)?(diff)?$'"

        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R

        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

        bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 1'
        bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 1'
        bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 1'
        bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 1'

        bind-key -T copy-mode-vi M-h resize-pane -L 1
        bind-key -T copy-mode-vi M-j resize-pane -D 1
        bind-key -T copy-mode-vi M-k resize-pane -U 1
        bind-key -T copy-mode-vi M-l resize-pane -R 1

        bind C-r source-file ~/.config/tmux/tmux.conf
      '';
  };

  programs.neovim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;
    defaultEditor = true;
    extraLuaConfig = ''
      require("tvim").init()
    '';
    extraPackages = with pkgs-unstable; [
      stylua
      luajitPackages.luacheck
      lua-language-server
      bash-language-server
      shellharden
      nodePackages.prettier
      eslint
      nixd
      statix
      nixpkgs-fmt
      tree-sitter
    ];
    #    configure = {
    #      customRc = ''
    #        lua << EOF
    #   require 'tvim'
    # EOF
    #      '';
    #      packages.main.start = [
    plugins = [
      (pkgs-unstable.vimUtils.buildVimPlugin {
        name = "tvim";
        src = ./nvim;
        dependencies = with pkgs-unstable.vimPlugins; [
          # editing/ui
          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects
          nvim-treesitter-context
          mini-nvim
          gruvbox-material
          render-markdown-nvim
          neorg
          neorg-telescope
          neogit
          conform-nvim
          nvim-lint
          lsp-progress-nvim
          tmux-nvim
          grapple-nvim
          grug-far-nvim

          # navigation
          fzf-lua

          # lsp
          blink-cmp
          nvim-lspconfig
          rustaceanvim
          friendly-snippets
          tiny-inline-diagnostic-nvim

          # dap
          nvim-dap
          nvim-dap-view
          nvim-dap-go
          nvim-dap-python
        ];
      })
    ];
    # plugins = [
    #   (pkgs-unstable.vimUtils.buildVimPlugin {
    #     name = "tvim";
    #     src = ./nvim;
    #     dependencies = with pkgs-unstable.vimPlugins; [
    #       # editing/ui
    #       nvim-treesitter.withAllGrammars
    #       nvim-treesitter-textobjects
    #       nvim-treesitter-context
    #       mini-nvim
    #       gruvbox-material
    #       render-markdown-nvim
    #       neorg
    #       neorg-telescope
    #       neogit
    #       conform-nvim
    #       nvim-lint
    #       lsp-progress-nvim
    #       tmux-nvim
    #       grapple-nvim
    #       grug-far-nvim
    #
    #       # navigation
    #       fzf-lua
    #
    #       # lsp
    #       blink-cmp
    #       nvim-lspconfig
    #       rustaceanvim
    #       friendly-snippets
    #       tiny-inline-diagnostic-nvim
    #
    #       # dap
    #       nvim-dap
    #       nvim-dap-view
    #       nvim-dap-go
    #       nvim-dap-python
    #     ];
    #   })
    # ];
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      "$mod" = "SUPER";
      exec = [
        # "wlsunset"
      ];
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
      ];
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
      master = {
        mfact = 0.5;
        orientation = "right";
      };
      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
        key_press_enables_dpms = true;
        mouse_move_enables_dpms = true;
      };
      windowrulev2 = [
        "float,title:^(Picture(.)in(.)picture$"
        "pin,title:^(Picture(.)in(.)picture)$"
        "float,class:^(steam)$,title:^(Friends list)$"
        "float,class:^(steam)$,title:^(Steam Settings)$"
        "workspace 3,class:^(steam)$"
        "workspace 3,class:^(lutris)$"
        "workspace 3,title:^(Wine System Tray)$"
        "workspace 4,class:^(battle.net.exe)$"
      ];
      bind = [
        "$mod, Space, exec, fuzzel"
        "$mod, Return, exec, [workspace 2] foot"
        "$mod, b, exec, [workspace 1] brave"
        "$mod, q, killactive"
        "$mod ALT, q, exit"
        "$mod, f, fullscreen, 1"
        "$mod ALT, f, fullscreen, 0"
        "$mod ALT, v, togglefloating,"

        "$mod, j, cyclenext,"
        "$mod, k, cyclenext, prev"
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
    };
    foot = {
      enable = true;
      settings = {
        main = {
          font = "Hack Nerd Font:size=14";
        };
      };
    };
    waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "river/tags" ];
        modules-center = [ ];
        modules-right = [ "pulseaudio" "battery" "cpu" "memory" "tray" "clock" ];
      };
    };
  };

  services = {
    mako = {
      enable = true;
    };
    syncthing.enable = true;
  };
}
