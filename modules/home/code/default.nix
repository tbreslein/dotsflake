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

    selected=""
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
  options.myHome.code = {
    enable = lib.mkEnableOption "Enable coding role";
    extraWMEnv = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    nvim-config = lib.mkOption {
      type = lib.types.enum [ "minimal" "big" ];
      default = "minimal";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs-unstable; [
        universal-ctags

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
      file = {
        ".luacheckrc".text = ''
          globals = { "vim" }
        '';

        ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotsflake/modules/home/code/${cfg.nvim-config}-nvim";
      };
    };

    myHome.syke = {
      code-repos =
        let
          buildUrl = x: "git@github.com:tbreslein/" + x + ".git";
        in
        lib.lists.map buildUrl [
          "capturedlambdav2"
          "shyr"
          "computer_enhance"
          "public_presentations"
          "private_presentations"
        ];
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
      neovim = {
        enable = true;
        package = pkgs-unstable.neovim-unwrapped;
        defaultEditor = true;
        plugins =
          if cfg.nvim-config == "big" then
            (with pkgs-unstable.vimPlugins; [
              # ui
              nvim-treesitter.withAllGrammars
              nvim-treesitter-context
              gruvbox-material

              # tooling
              conform-nvim
              nvim-lint

              # navigation
              plenary-nvim
              telescope-nvim
              telescope-zf-native-nvim

              # lsp
              blink-cmp
              friendly-snippets
              nvim-lspconfig

              # dap
              nvim-dap
              nvim-dap-view
              nvim-dap-go
              nvim-dap-python
            ]) else
            (with pkgs-unstable.vimPlugins; [
              nvim-treesitter.withAllGrammars
              gruvbox-material
            ]);
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
        terminal = "alacritty";
        extraConfig =
          /*
        tmux
          */
          ''
            set -sa terminal-overrides ",alacritty:RGB"

            bind-key -r C-f run-shell "tmux new-window ${tmux-sessionizer}/bin/tmux-sessionizer"
            bind-key C-g new-window -n lazygit -c "#{pane_current_path}" "lazygit"
            bind-key C-o command-prompt -p "open app: " "new-window '%%'"

            bind-key C-s split-pane -l 30%
            bind-key C-v split-pane -h -b -l 40%

            # set -g status-interval 2
            set -g status-style "fg=colour3 bg=colour0"
            set -g status-left-length 200
            set -g status-right-length 300
            set -g status-right "#(cd #{pane_current_path}; ${git-status}/bin/git-status)"

            bind-key -r C-h select-pane -L
            bind-key -r C-j select-pane -D
            bind-key -r C-k select-pane -U
            bind-key -r C-l select-pane -R
            bind-key -r M-h resize-pane -L 1
            bind-key -r M-j resize-pane -D 1
            bind-key -r M-k resize-pane -U 1
            bind-key -r M-l resize-pane -R 1

            bind C-r source-file ~/.config/tmux/tmux.conf
          '';
      };
      zed-editor = {
        inherit (config.myHome.linux) enable;
        extensions = [
          # syntax ++ languages
          "angular"
          "assembly"
          "astro"
          "awk"
          "basher"
          "csv"
          "dockerfile"
          "elisp"
          "elm"
          "env"
          "fortran"
          "golangci-lint"
          "haskell"
          "html"
          "hyprlang"
          "julia"
          "log"
          "lua"
          "make"
          "mermaid"
          "neocmake"
          "nix"
          "ocaml"
          "odin"
          "org"
          "roc"
          "scss"
          "svelte"
          "tmux"
          "toml"
          "typst"
          "uiua"
          "zig"

          # themes
          "gruber-darker"
          "gruvbox-material"
        ];
        userKeymaps = [
          {
            context = "Workspace && vim_mode == normal";
            bindings = {
              "ctrl-\\" = "terminal_panel::ToggleFocus";
              "space f o" = "project_panel::ToggleFocus";
              "space Q" = "workspace::CloseAllDocks";
              "space H" = "workspace::ToggleLeftDock";
              "space L" = "workspace::ToggleRightDock";
              "space J" = "workspace::ToggleBottomDock";
            };
          }
          {
            context = "EmptyPane || SharedScreen || (Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu)";
            bindings = {
              "space f f" = "file_finder::Toggle";
              "space f p" = "projects::OpenRecent";
            };
          }
          {
            context = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
            bindings = {
              # git
              "space g d" = "editor::ToggleSelectedDiffHunks";
              "space g g" = "git_panel::ToggleFocus";

              # finder
              "space f s" = "pane::DeploySearch";

              # Open markdown preview
              "space m p" = "markdown::OpenPreview";
              "space m P" = "markdown::OpenPreviewToTheSide";

              # Chat with AI
              "space a c" = "assistant::ToggleFocus";

              # misc
              # "j k" = ["workspace::SendKeystrokes", "escape"];
              "g f" = "editor::OpenExcerpts";
              "space z z" = "workspace::ToggleCenteredLayout";
            };
          }
          {
            context = "Editor && (showing_code_actions || showing_completions) && vim_mode == insert";
            bindings = {
              "ctrl-j" = "editor::ContextMenuNext";
              "ctrl-k" = "editor::ContextMenuPrevious";
              "enter" = null;
            };
          }
          {
            context = "Editor && showing_completions";
            bindings = {
              "ctrl-l" = "editor::ConfirmCompletion";
            };
          }
          {
            context = "Editor && showing_code_actions";
            bindings = {
              "ctrl-l" = "editor::ConfirmCodeAction";
            };
          }
          {
            context = "Editor && vim_mode == normal && !VimWaiting && !menu";
            bindings = {
              # lsp
              "g t i" = "editor::ToggleInlayHints";
              # "g a"= "editor::ToggleCodeActions";
              # "g n"= "editor::Rename";
              # "g d"= "editor::GoToDefinition";
              # "g D"= "editor::GoToDefinitionSplit";
              # "g i"= "editor::GoToImplementation";
              # "g I"= "editor::GoToImplementationSplit";
              # "g t"= "editor::GoToTypeDefinition";
              # "g T"= "editor::GoToTypeDefinitionSplit";
              # "g r"= "editor::FindAllReferences";
              # "] d"= "editor::GoToDiagnostic";
              # "[ d"= "editor::GoToPreviousDiagnostic";
              # "g s s"= "outline::Toggle";
              # "g s S"= "project_symbols::Toggle";
              # "g x x"= "diagnostics::Deploy";

              # git
              "] h" = "editor::GoToHunk";
              "[ h" = "editor::GoToPreviousHunk";
              "space g h" = "editor::GoToPreviousHunk";
            };
          }
          # navigation
          {
            context = "(Editor && vim_mode == normal && !VimWaiting && !menu) || GitPanel";
            bindings = {
              # Switch between buffers
              "shift-h" = "pane::ActivatePreviousItem";
              "shift-l" = "pane::ActivateNextItem";
              # Close active panel
              "shift-q" = "pane::CloseActiveItem";
              "ctrl-q" = "pane::CloseActiveItem";
              "space b d" = "pane::CloseActiveItem";
              "space b o" = "pane::CloseInactiveItems";
            };
          }
          {
            context = "Dock || Editor";
            bindings = {
              "ctrl-h" = "workspace::ActivatePaneLeft";
              "ctrl-l" = "workspace::ActivatePaneRight";
              "ctrl-k" = "workspace::ActivatePaneUp";
              "ctrl-j" = "workspace::ActivatePaneDown";
            };
          }
          {
            context = "GitPanel";
            bindings = {
              "q" = "git_panel::Close";
              "space g g" = "git_panel::ToggleFocus";
              # TODO: git diff is not ready yet, refer https://github.com/zed-industries/zed/issues/8665#issuecomment-2194000497
            };
          }
          # File panel (netrw)
          {
            context = "ProjectPanel && not_editing";
            bindings = {
              "a" = "project_panel::NewFile";
              "A" = "project_panel::NewDirectory";
              "r" = "project_panel::Rename";
              "d" = "project_panel::Delete";
              "x" = "project_panel::Cut";
              "c" = "project_panel::Copy";
              "p" = "project_panel::Paste";
              "q" = "workspace::ToggleLeftDock";
            };
          }
        ];

        userSettings = {
          theme = {
            mode = "system";
            light = "Gruvbox Light Hard";
            dark = "Gruvbox Material";
          };
          features = {
            edit_prediction_provider = "zed";
          };
          buffer_font_family = "Hack Nerd Font";
          buffer_font_features = {
            calt = false;
          };
          buffer_font_size = 17;
          ui_font_family = "Zed Plex Sans";
          ui_font_features = {
            calt = false;
          };
          ui_font_size = 17;
          unnecessary_code_fade = 0.3;
          active_pane_modifiers = {
            inactive_opacity = 0.5;
          };
          pane_split_direction_horizontal = "down";
          pane_split_direction_vertical = "right";
          centered_layout = {
            left_padding = 0.2;
            right_padding = 0.2;
          };
          vim_mode = true;
          when_closing_with_no_tabs = "close_window";
          on_last_window_closed = "quit_app";
          use_system_path_prompts = false;
          cursor_blink = false;
          cursor_shape = "block";
          current_line_highlight = "gutter";
          auto_signature_help = true;
          show_wrap_guides = true;
          wrap_guides = [ 80 ];
          use_autoclose = false;
          use_auto_surround = false;
          # Settings related to calls in Zed
          calls = {
            mute_on_join = true;
          };
          toolbar = {
            breadcrumbs = true;
            quick_actions = false;
            selections_menu = false;
          };
          scrollbar = {
            show = "never";
          };
          relative_line_numbers = true;
          use_smartcase_search = true;
          inlay_hints = {
            enabled = false;
            show_type_hints = true;
            show_parameter_hints = false;
          };
          project_panel = {
            button = false;
            default_width = 300;
          };
          outline_panel = {
            button = false;
            default_width = 300;
            dock = "right";
          };
          collaboration_panel = {
            button = false;
          };
          git_panel = {
            button = false;
          };
          max_tabs = null;
          tab_bar = {
            # Whether or not to show the tab bar in the editor
            show = true;
            show_nav_history_buttons = false;
            show_tab_bar_buttons = false;
          };
          tabs = {
            file_icons = true;
            activate_on_close = "left_neighbour";
          };
          telemetry = {
            diagnostics = false;
            metrics = false;
          };
          diagnostics = {
            include_warnings = true;
            inline = {
              enabled = true;
            };
          };
          git = {
            git_gutter = "hide";
            inline_blame = {
              enabled = false;
            };
          };
          load_direnv = "shell_hook";
          journal = {
            path = "~/zed_journal";
            hour_format = "hour24";
          };
          # Settings specific to the terminal
          terminal = {
            blinking = "off";
            cursor_shape = "block";
            option_as_meta = true;
            copy_on_select = true;
            button = false;
            # Activate the python virtual environment, if one is found, in the
            # terminal's working directory (as resolved by the working_directory
            # setting). Set this to "off" to disable this behavior.
            detect_venv = {
              on = {
                # Default directories to search for virtual environments, relative
                # to the current working directory. We recommend overriding this
                # in your project's settings, rather than globally.
                directories = [ ".env" "env" ".venv" "venv" ];
              };
            };
          };
          jupyter = {
            enabled = true;
            # Specify the language name as the key and the kernel name as the value.
            # "kernel_selections": {
            #    "python": "conda-base"
            #    "typescript": "deno"
            # }
          };
          vim = {
            default_mode = "normal";
            custom_digraphs = { };
          };
          line_indicator_format = "short";
          # Set to configure aliases for the command palette.
          # When typing a query which is a key of this object, the value will be used instead.
          #
          # Examples:
          # {
          #   "W": "workspace::Save"
          # }
          languages = {
            Python = {
              language_servers = [ "pyright" "!pylsp" "..." ];
            };
          };
          command_aliases = { };
          ssh_connections = [ ];
        };
      };
    };
  };
}
