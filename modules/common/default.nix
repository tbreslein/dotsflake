{ config, lib, pkgs, user-conf, ... }:

let
  cfg = config.my-system;
in
{
  imports = [
    ./bash.nix
    ./code
    ./tmux.nix
    ./ghostty.nix
    ./alacritty.nix
    ./kanata.nix
    ./git.nix
    ./jujutsu.nix
    ./syke.nix
  ];

  options.my-system = {
    terminal = lib.mkOption {
      type = with lib.types; enum [ "ghostty" "foot" "alacritty" ];
    };
    terminal-font-size = lib.mkOption {
      type = lib.types.int;
    };
    has-gui = lib.mkEnableOption "has a GUI";
  };

  config = {
    users.users.${user-conf.name}.home = user-conf.home-dir;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    environment.systemPackages = with pkgs; [
      vim
      tree
      wget
      git
      gnumake
      tmux
      ccrypt
      gnutar
      htop
      bat
      rm-improved
      htop
      caligula
      silver-searcher

      alacritty.terminfo
      (
        let
          nvd = "${pkgs.nvd}/bin/nvd";
          nix-bin-dir = "${config.nix.package}/bin";
          sys = if user-conf.is-linux then "nixos" else "darwin";
        in
        writeShellScriptBin "dm" /*bash*/
          ''
            set -euo pipefail
            cd ${user-conf.dots-dir}
            if [ $# -gt 0 ]; then
              case $1 in
                u) nix flake update;;
                *);;
              esac
            fi
            deriv=$(${nix-bin-dir}/nix build --no-link --print-out-paths path:.#${sys}Configurations.${user-conf.hostname}.config.system.build.toplevel)
            ${nvd} --nix-bin-dir=${nix-bin-dir} diff /run/current-system $deriv

            read -p "Continue? [Y/n]: " confirm
            case $confirm in
              y|Y|"") sudo ${sys}-rebuild switch --flake ${user-conf.dots-dir}#${user-conf.hostname};;
              n|N) exit 0;;
              *) echo "that's neither yes or no"; exit 1;;
            esac
          ''
      )
    ];

    home-manager.users.${user-conf.name} = {
      fonts.fontconfig.enable = cfg.has-gui;
      home = {
        packages = if cfg.has-gui then [ pkgs.nerd-fonts.hack ] else [ ];
        sessionVariables = {
          EDITOR = lib.mkDefault "vim";
          VISUAL = lib.mkDefault "vim";
        };
        sessionPath = lib.lists.map (x: "${user-conf.home-dir}/${x}") [
          ".cargo/bin"
          ".local/bin"
          "bin"
        ];
        username = user-conf.name;
        stateVersion = "25.05";
        shell.enableBashIntegration = true;
        shellAliases = {
          m = "make";
          ls = "ls --color=auto";
          la = "ls -aa";
          ll = "ls -l";
          lla = "ls -la";
          lt = "tree";
          cp = "cp -i";
          mv = "mv -i";
          rm = "rm -i";
          mkdir = "mkdir -p";
          grep = "grep --color=auto";
        };
      };
      programs = {
        home-manager.enable = true;
        ripgrep.enable = true;
        fastfetch.enable = true;
        tealdeer.enable = true;
        fzf.enable = true;
        fzf.enableBashIntegration = true;
      };
    };
  };
}
