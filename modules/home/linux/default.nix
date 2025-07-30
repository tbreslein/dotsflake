{ config, lib, ... }:
let
  cfg = config.my-home.linux;
in
{
  imports = [
    ./desktop
    ./nvidia
  ];

  options.my-home.linux.enable = lib.mkEnableOption "Enable home linux role";

  config = lib.mkIf cfg.enable {
  };
}
