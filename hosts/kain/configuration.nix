{ ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  mySystem = {
    desktop.linux = {
      enable = true;
      extraUserPackages = [ ];
      extraSystemPackages = [ ];
    };
    gaming.enable = true;
  };
}
