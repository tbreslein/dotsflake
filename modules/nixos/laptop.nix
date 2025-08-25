{ config, lib, pkgs, user-conf, ... }:

let
  cfg = config.my-system.nixos.laptop;
in
{
  options.my-system.nixos.laptop = {
    enable = lib.mkEnableOption "Enable nixos.laptop";
  };

  config = lib.mkIf cfg.enable {
    # networking.wireless.enable = true;
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
      };
    };
  };
}

