{ config
, lib
, ...
}:
let
  cfg = config.my-home.darwin;
in
{
  options.my-home.darwin.enable = lib.mkEnableOption "Enable my-home.darwin";

  config = lib.mkIf cfg.enable {
    home.shellAliases.mocostate = "tail -10 /tmp/mococlient.err.log";
    programs.bash = {
      profileExtra = /* bash */ ''
        [[ -f "/opt/homebrew/bin/brew" ]] && \
          eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      bashrcExtra = /* bash */ ''
        twork() {
          if [ "$TMUX" != "" ]; then
            if ! tmux has-session -t work; then
              tmux new-session -ds "work" -c "${config.my-home.work-dir}"
            fi
          else
            tmux new-session -ds "work" -c "${config.my-home.work-dir}"
            tmux a -t "work"
          fi
        }
      '';
    };
  };
}
