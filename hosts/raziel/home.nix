{ config, pkgs, ... }:

{
  myHome = {
    code = {
      enable = true;
      tmux-terminal = "foot";
    };
  };
}
