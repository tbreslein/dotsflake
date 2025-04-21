{ pkgs-unstable, ... }:

{
  nix = {
    settings.extra-experimental-features = [ "nix-command" "flakes" ];
    gc.automatic = true;
  };
  home = {
    username = "tommy";
    packages = with pkgs-unstable; [
      nerd-fonts.hack
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
