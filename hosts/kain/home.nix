_:

{
  myHome = {
    code.enable = true;
    linux = {
      enable = true;
      amd-cpu.enable = true;
      desktop.enable = true;
      nvidia.enable = true;
      gaming.enable = true;
    };
    desktop.enable = true;
    desktop.terminalFontSize = 25;
    syke = {
      enable = true;
      arch.enable = true;
      systemd.enable = true;
      arch.aur-pkgs = [
        "linux-cachyos"
        "linux-cachyos-headers"
      ];
    };
  };
}
