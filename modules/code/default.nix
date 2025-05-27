{ config
, lib
, pkgs-unstable
, ...
}:
let
  cfg = config.myHome.code;
  tmux-sessionizer = pkgs-unstable.writeShellScriptBin "tmux-sessionizer" /* bash */ ''
    folders=("''\$HOME")
    add_dir() {
      [ -d "''\$HOME/''\$1" ] && folders+=("''\$HOME/''\$1")
    }
    add_dir "code"
    add_dir "work/repos"

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
  options = {
    myHome.code = {
      enable = lib.mkEnableOption "Enable coding role";
      tmux-terminal = lib.mkOption {
        type = lib.types.str;
        default = "alacritty";
        description = "Which default terminal and oversides to set for tmux";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      file.".luacheckrc" = {
        text = ''
          globals = { "vim" }
        '';
      };
    };

    editorconfig = {
      enable = true;
      settings = {
        "*" = {
          charset = "utf-8";
          indent_size = 4;
          indent_style = "space";
          max_line_width = 80;
          trim_trailing_whitespace = true;
        };
        "*.{nix,cabal,hs,lua}" = {
          indent_size = 2;
        };
        "*.{json,js,jsx,ts,tsx,cjs,mjs}" = {
          indent_size = 2;
        };
        "*.{yml,yaml,ml,mli,hl,md,mdx,html,astro}" = {
          indent_size = 2;
        };
        "CMakeLists.txt" = {
          indent_size = 2;
        };
        "{m,M}akefile" = {
          indent_style = "tab";
        };
      };
    };

    programs = {
      jq.enable = true;
      lazygit.enable = true;
      neovim = {
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
              neogit
              conform-nvim
              nvim-lint
              tmux-nvim
              harpoon2
              plenary-nvim

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
        withNodeJs = false;
        withPython3 = false;
        withRuby = false;
      };
      tmux = {
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
            ${if cfg.tmux-terminal == "" then "" else ''
              set -g default-terminal "${cfg.tmux-terminal}"
              set -sa terminal-overrides ",${cfg.tmux-terminal}:RGB"
            ''}

            bind-key -r C-f run-shell "tmux new-window ${tmux-sessionizer}/bin/tmux-sessionizer"
            bind-key C-g new-window -n gitu -c "#{pane_current_path}" "lazygit"
            bind-key C-o command-prompt -p "open app: " "new-window '%%'"

            bind-key C-s split-pane -l 30%
            bind-key C-v split-pane -h -b -l 40%

            # set -g status-interval 2
            set -g status-style "fg=colour3 bg=colour0"
            set -g status-left-length 200
            set -g status-right-length 300
            #set -g status-left "#S || "
            set -g status-right "#(cd #{pane_current_path}; ${git-status}/bin/git-status)"

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
    };
  };
}
