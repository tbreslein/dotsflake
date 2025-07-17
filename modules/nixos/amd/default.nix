{ config, lib, ... }:
let
  cfg = config.my-system.nixos.amd;
in
{
  options.my-system.nixos.amd.enable = lib.mkEnableOption "enable my-system.nixos.amd";

  config = lib.mkIf cfg.enable {
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
