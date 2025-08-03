{ config, lib, pkgs, hm, user-conf, ... }:
let
  cfg = config.my-system.tmux;

  tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" /* bash */ ''
    folders=("''\$HOME")
    add_dir() {
      [ -d "$1" ] && folders+=("$1")
    }
    add_dir "${user-conf.code-dir}"
    add_dir "${user-conf.sync-dir}"
    add_dir "${user-conf.work-dir}/repos"

    selected=""
    if [[ ''\$# -eq 1 ]]; then
      selected=''\$1
    else
      selected=''\$(fd -td --exact-depth 1 . ''\${folders[@]} | fzy)
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

  git-status = pkgs.writeShellScriptBin "git-status" /* bash */ ''
    if git rev-parse >/dev/null 2>&1; then
      result=" ''\$(git rev-parse --abbrev-ref HEAD) "
      echo "''\$result"
    else
      echo ""
    fi
  '';
in
{
  options.my-system.tmux.enable = lib.mkEnableOption "Enable tmux";

  config = lib.mkIf cfg.enable {
    ${hm}.programs = {
      bash.bashrcExtra = /* bash */ ''
        td() {
          local session="notes"
          local notes_dir="${user-conf.sync-dir}/notes"
          if [ "$TMUX" != "" ]; then
            if ! tmux has-session -t "$session"; then
              tmux new-session -ds "$session" -c "$notes_dir" "nvim $notes_dir/todos.md"
            fi
          else
            tmux new-session -ds "$session" -c "$notes_dir" "nvim $notes_dir/todos.md"
            tmux a -t "$session"
          fi
        }
      '';

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
            set -g allow-passthrough on
            #set -ga update-environment TERM
            #set -ga update-environment TERM_PROGRAM

            bind-key -r C-f run-shell "tmux popup -E -w80 -h11 ${tmux-sessionizer}/bin/tmux-sessionizer"
            bind-key C-o command-prompt -p "open app: " "popup -E -w90% -h90% '%%'"
            bind-key C-space popup -w90% -h90%

            bind-key C-s split-pane -l 30%
            bind-key C-v split-pane -h -b -l 40%

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
    };
  };
}
