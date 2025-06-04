{ config, lib, ... }:
let
  cfg = config.myHome.linux.amd-cpu;
in
{
  options.myHome.linux.amd-cpu.enable = lib.mkEnableOption "Enable home linux.amd-cpu role";

  config = lib.mkIf cfg.enable {
    myHome.syke.arch.pacman-pkgs = [
      "amd-ucode"
    ];
  };
}
