{ config, lib, pkgs, userConf, inputs, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  imports = [
    ./gaming
  ];

  options.mySystem.desktop.enable = lib.mkEnableOption "enable nixos.desktop";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        (inputs.zen-browser.packages.${system}.twilight-official.override {
          extraPolicies = {
            DisableAppUpdate = true;
            DisableTelemetry = true;
          };
        })
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
              user = userConf.name;
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
