{ pkgs-unstable, ... }:

{
  imports = [
    ./code
    ./desktop
  ];

  nix = {
    settings.extra-experimental-features = [ "nix-command" "flakes" ];
    gc.automatic = true;
  };
  home = {
    username = "tommy";
    packages = with pkgs-unstable; [
      nerd-fonts.hack
      nerd-fonts._3270
      nerd-fonts.departure-mono
      htop

      fzf
      ripgrep
      fd
      bat
      lazygit
      gitu
    ];
    stateVersion = "24.11";
  };

  programs = {
    home-manager.enable = true;
  };
}
