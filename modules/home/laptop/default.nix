{ config, lib, pkgs-unstable, ... }:

let
  cfg = config.myHome.laptop;
in
{
  options.myHome.linux = {
    enable = lib.mkEnableOption "Enable home laptop role";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs-unstable.kanata ];
    file.".config/kanata/kanata.kbd".text = /* kbd */ ''
      (defcfg
        macos-dev-names-include ("Apple Internal Keyboard / Trackpad")
        process unmapped-keys yes
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
}
