{ config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.bash;
in
{
  options.my-system.bash.enable = lib.mkEnableOption "Enable bash";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name}.programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "erasedups" "ignorespace" ];
        historyIgnore = [ "ls" "lt" "lla" "la" "tree" "cd" "z" "pushd" "popd" "exit" ];
        shellOptions = [
          "autocd"
          "checkjobs"
          "checkwinsize"
          "extglob"
          "globstar"
          "nocaseglob"
          "histappend"
        ];
        initExtra = /* bash */  ''
        '';
        bashrcExtra = /* bash */ ''
          export PS1='\n[$?] \[\033[1m\]\h: \w\[\033[0m\]\n\[\033[33;1m\]$\[\033[0m\] '
        '';
        logoutExtra = /* bash */ ''
        '';
      };

      readline = {
        enable = true;
        extraConfig = /* bash */ ''
          set editing-mode vi
          set colored-stats on
          set colored-completion-prefix on
          set completion-ignore-case on
        '';
      };
    };
  };
}
