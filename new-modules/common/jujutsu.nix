{ config, lib, pkgs, hm, user-conf, ... }:

let
  cfg = config.my-system.jujutsu;
in
{
  options.my-system.jujutsu.enable = lib.mkEnableOption "Enable jujutsu";

  config = lib.mkIf cfg.enable {
    ${hm}.programs.jujutsu = {
      enable = false;
      settings = {
        user.name = user-conf.github-name;
        user.email = user-conf.email;
        ui.editor = "nvim";
        "--scope" = [
          {
            "--when.repositories" = [ "${user-conf.work-dir}" ];
            user.name = user-conf.work-gitlab-name;
            user.email = user-conf.work-email;
          }
        ];
      };
    };
  };
}
