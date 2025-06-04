{ config, lib, ... }:
let
  cfg = config.myHome.linux.laptop;
in
{
  options.myHome.linux.laptop.enable = lib.mkEnableOption "Enable home linux.laptop role";

  config = lib.mkIf cfg.enable {
    myHome.syke = {
      systemd = {
        services-enabled = [
          "tlp"
        ];
        services-masked = [
          "systemd-rfkill.socket"
          "systemd-rfkill.service"
        ];
      };
      arch.pacman-pkgs = [
        "tlp"
      ];
    };
  };
}
