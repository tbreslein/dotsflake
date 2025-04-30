{ config, pkgs, ... }:

{
  # home.homeDirectory = "/Users/tommy/";
  myHome = {
    code = {
      enable = true;
      tmux-terminal = "xterm-ghostty";
    };
  };
  # launchd = {
  #   enable = true;
  #   agents.moco.config = {
  #     ProgramArguments = [ "${pkgs-stable.poetry}" "run" "python" "moco_client.py" ];
  #     WorkingDirectory = "${config.home.homeDirectory}/work/repos/mocotrackingclient";
  #   };
  # };
}
