{ inputs, config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.code.emacs;
in
{
  options.my-system.code.emacs = {
    enable = lib.mkEnableOption "Enable emacs";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name} = { config, ... }: {
      home = {
        packages = [ pkgs.emacs-lsp-booster ];
        file = {
          ".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink "${user-conf.dots-dir}/modules/common/code/emacs.el";
          ".emacs.d/early-init.el".source = config.lib.file.mkOutOfStoreSymlink "${user-conf.dots-dir}/modules/common/code/emacs-early-init.el";
        };
      };
      programs.emacs.enable = true;
    };
  };
}
