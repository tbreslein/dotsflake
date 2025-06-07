{ config
, lib
  # , pkgs-stable
, ...
}:
let
  cfg = config.myHome.darwin;
in
{
  options = {
    myHome.darwin = {
      enable = lib.mkEnableOption "Enable home darwin";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jankyborders = {
      enable = false;
      # TODO
    };
    launchd = {
      enable = false;
      # TODO
      # agents.moco.config = {
      #   ProgramArguments = [ "${pkgs-stable.poetry}" "run" "python" "moco_client.py" ];
      #   WorkingDirectory = "${config.home.homeDirectory}/work/repos/mocotrackingclient";
      # };
    };
    targets.darwin = {
      # TODO
    };
  };
}
