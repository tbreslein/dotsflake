_:

{
  home.homeDirectory = "/home/tommy";
  myHome = {
    code = {
      enable = true;
      tmux-terminal = "alacritty";
    };
    linux = {
      enable = true;
      terminalFontSize = 17;
      extraWMEnv = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
    };
  };
}
