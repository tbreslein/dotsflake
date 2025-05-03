{ config, pkgs, ... }:

{
  myHome = {
    code = {
      enable = true;
      tmux-terminal = "xterm-ghostty";
    };
    # desktop.darwin = {
    #   enable = true;
    # };
  };
  # launchd = {
  #   enable = true;
  #   agents.moco.config = {
  #     ProgramArguments = [ "${pkgs-stable.poetry}" "run" "python" "moco_client.py" ];
  #     WorkingDirectory = "${config.home.homeDirectory}/work/repos/mocotrackingclient";
  #   };
  # };
}
