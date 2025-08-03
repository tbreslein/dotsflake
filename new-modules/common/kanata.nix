{ config, lib, pkgs, hm, ... }:

let
  cfg = config.my-system.kanata;
in
{
  options.my-system.kanata.enable = lib.mkEnableOption "Enable my-system.kanata";

  config = lib.mkIf cfg.enable {
    ${hm} = {
      home = {
        packages = [ pkgs.kanata ];
        # setup kanata for macos:
        # install karabiner elements and walk through the full setup
        # add kanata and ghostty to Settings > Privacy & Security > Input Monitoring
        # launch kanata with sudo
        file.".config/kanata/kanata.kbd".text = /* kbd */ ''
          (defcfg
            macos-dev-names-include (
              "Apple Internal Keyboard / Trackpad"
            )
            process-unmapped-keys yes
          )
          (defsrc
            a s d f j k l ;
          )
          (defvar
            tap-time 200
            hold-time 150
          )
          (defalias
            hm-a (tap-hold $tap-time $hold-time a lmet)
            hm-s (tap-hold $tap-time $hold-time s lalt)
            hm-d (tap-hold $tap-time $hold-time d lsft)
            hm-f (tap-hold $tap-time $hold-time f lctl)
            hm-j (tap-hold $tap-time $hold-time j rctl)
            hm-k (tap-hold $tap-time $hold-time k rsft)
            hm-l (tap-hold $tap-time $hold-time l lalt)
            hm-; (tap-hold $tap-time $hold-time ; rmet)
          )
          (deflayer base
            @hm-a  @hm-s  @hm-d  @hm-f  @hm-j  @hm-k  @hm-l  @hm-;
          )
        '';
      };
      programs.bash.bashrcExtra = /* bash */ ''
        toggle_kanata() {
          local kanatadir="${config.home.homeDirectory}/.config/kanata/"
          if ! tmux has-session -t "kanata" 2>/dev/null; then
            tmux new-session -ds "kanata" -c "$kanatadir"
            ${if pkgs.stdenv.isLinux
              then "tmux send-keys -t kanata 'kanata -c ./kanata.kbd' C-m"
              else ("tmux send-keys -t kanata 'sudo kanata -c ./kanata.kbd'" +
                " && tmux switch-client -t kanata")}
          else
            tmux kill-session -t "kanata"
          fi
        }
      '';
    };
  };
}
