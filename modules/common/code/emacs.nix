{ inputs, config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.code.emacs;
in
{
  options.my-system.code.emacs = {
    enable = lib.mkEnableOption "Enable neovim";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name} = { config, ... }: {
      programs.emacs.enable = true;
    };
  };
}
