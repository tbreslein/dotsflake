{ config, lib, pkgs, inputs, system, userConf, modulesPath, ... }:

{
  imports =
    [
      # ./hardware-configuration.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "nvidia" "nvidia_uvm" "nvidia_drm" ];
      luks.devices = {
        "luks-d8adffba-0292-444c-b024-8d82576daa90".device = "/dev/disk/by-uuid/d8adffba-0292-444c-b024-8d82576daa90";
        "luks-acb1a670-3394-4665-a5f1-0ffeb161d3a2".device = "/dev/disk/by-uuid/acb1a670-3394-4665-a5f1-0ffeb161d3a2";
      };
    };
    kernelModules = [ "kvm-amd" ];
    # TODO: cachy kernel
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

    loader = {
      timeout = 1;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
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

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "sol";
    networkmanager.enable = true;
    firewall.enable = true;
  };


  nixpkgs.hostPlatform = system;

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics.enable = true;
    graphics.enable32Bit = true;
    nvidia = {
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.syncthing = {
    openDefaultPorts = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tommy = {
    isNormalUser = true;
    description = "tommy";
    extraGroups = [ "networkmanager" "wheel" "games" "gamemode" ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gnumake

    mangohud
    protonup

    (inputs.zen-browser.packages.${system}.twilight-official.override
      {
        extraPolicies = {
          DisableAppUpdate = true;
          DisableTelemetry = true;
        };
      })

    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];
      extraPkgs = pkgs: [
        wine-staging
        winetricks
        protontricks
      ];
    })
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.gamemode.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  services.greetd = {
    enable = true;
    settings =
      let
        session = "${pkgs.hyprland}/bin/Hyprland";
        tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
      in
      {
        initial_session = {
          command = session;
          user = userConf.name;
        };
        default_session = {
          # run tuigreet, when quitting the initial_session
          command = "${tuigreet} --asterisks --remember --remember-user-session --time --cmd ${session}";
          user = "greeter";
        };
      };
  };
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;


  system.stateVersion = "25.05";

}
