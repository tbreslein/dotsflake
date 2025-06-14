{ config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking = {
    wireless.enable = false;
    hostName = "sol";
  };
  boot = {
    fsck = false;
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "nvidia" "nvidia_uvm" "nvidia_drm" ];
      luks.devices = {
        "luks-d8adffba-0292-444c-b024-8d82576daa90".device = "/dev/disk/by-uuid/d8adffba-0292-444c-b024-8d82576daa90";
        "luks-acb1a670-3394-4665-a5f1-0ffeb161d3a2".device = "/dev/disk/by-uuid/acb1a670-3394-4665-a5f1-0ffeb161d3a2";
      };
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/dc64c0cb-7435-406f-9e04-b7566653beb1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/EE07-EF7E";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
  swapDevices =
    [{ device = "/dev/disk/by-uuid/6a149b86-6f4a-4016-bdec-eb0a4de5aeb3"; }];

  mySystem = {
    desktop.enable = true;
    desktop.gaming.enable = true;
    amd.enable = true;
    nvidia.enable = true;
  };
}
