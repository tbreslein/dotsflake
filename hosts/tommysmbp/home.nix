_:

{
  myHome = {
    code.enable = true;
    syke.enable = true;
    desktop.enable = true;
    desktop.terminalFontSize = 24;
  };
  # launchd = {
  #   enable = true;
  #   agents.moco.config = {
  #     ProgramArguments = [ "${pkgs-stable.poetry}" "run" "python" "moco_client.py" ];
  #     WorkingDirectory = "${config.home.homeDirectory}/work/repos/mocotrackingclient";
  #   };
  # };
}
