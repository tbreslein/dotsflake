{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      luks.devices = {
        "luks-a79966a2-44db-4182-92bc-f70f98e88a04".device = "/dev/disk/by-uuid/a79966a2-44db-4182-92bc-f70f98e88a04";
        "luks-7dbb567d-f876-43ac-ba87-2c573d172776".device = "/dev/disk/by-uuid/7dbb567d-f876-43ac-ba87-2c573d172776";
      };
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/b209aa23-dd78-4947-a6fa-ade3c46528ac";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/D3B7-58A8";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/eb8fb242-6940-42db-abca-ac2cfd71bf52"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
