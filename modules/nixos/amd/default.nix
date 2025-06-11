{ config, lib, ... }:
let
  cfg = config.mySystem.amd;
in
{
  options.mySystem.amd.enable = lib.mkEnableOption "enable nixos.amd";

  config = lib.mkIf cfg.enable {
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
