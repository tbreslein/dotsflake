{ config, lib, pkgs, user-conf, inputs, ... }:
let
  cfg = config.my-system.nixos.desktop;
in
{
  imports = [
    ./gaming
  ];

  options.my-system.nixos.desktop.enable = lib.mkEnableOption "enable my-system.nixos.desktop";

  config = lib.mkIf cfg.enable {
    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      loader = {
        timeout = 1;
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        # brave
        (inputs.zen-browser.packages.${system}.twilight-official.override {
          extraPolicies = {
            DisableAppUpdate = true;
            DisableTelemetry = true;
          };
        })
        kdePackages.breeze-gtk
        kdePackages.breeze-icons
        capitaine-cursors
      ];
      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        NIXOS_OZONE_WL = "1";
      };
    };

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      greetd = {
        enable = true;
        settings =
          let
            session = "${pkgs.hyprland}/bin/Hyprland";
            tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
          in
          {
            initial_session = {
              command = session;
              user = user-conf.name;
            };
            default_session = {
              # run tuigreet, when quitting the initial_session
              command = "${tuigreet} --asterisks --remember --remember-user-session --time --cmd ${session}";
              user = "greeter";
            };
          };
      };
    };
  };
}
