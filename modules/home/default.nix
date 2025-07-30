{ config, lib, pkgs, user-conf, hostname, ... }:

let
  cfg = config.my-home;
  syncthing-server = "elphelt";
in
{
  imports = [
    ./code
    ./linux
    ./darwin
    ./syke
    ./desktop
    ./laptop
  ];

  options.my-home = {
    enable = lib.mkEnableOption "Enable home role";
    code-dir = lib.mkOption {
      type = lib.types.str;
      default = config.home.homeDirectory + "/Documents/code";
    };
    dots-dir = lib.mkOption {
      type = lib.types.str;
      default = cfg.code-dir + "/dotsflake";
    };
    work-dir = lib.mkOption {
      type = lib.types.str;
      default = config.home.homeDirectory + "/work";
    };
    sync-dir = lib.mkOption {
      type = lib.types.str;
      default = config.home.homeDirectory + "/sync";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      username = user-conf.name;
      packages = with pkgs; [
        fzy
        bat
        rm-improved
        tmux

        (
          let
            nvd = "${pkgs.nvd}/bin/nvd";
            nix-bin-dir = "${config.nix.package}/bin";
            sys = if pkgs.stdenv.isLinux then "nixos" else "darwin";
            doas = if pkgs.stdenv.isLinux then "doas" else "sudo";
            activate =
              if pkgs.stdenv.isLinux
              then "bin/switch-to-configuration switch"
              else "activate switch";
          in
          writeShellScriptBin "dm" /*bash*/
            ''
              set -euo pipefail
              cd ${cfg.dots-dir}
              if [ $# -gt 0 ]; then
                case $1 in
                  u) nix flake update;;
                  *);;
                esac
              fi
              # sudo ${sys}-rebuild switch --flake ${cfg.dots-dir}#${hostname}
              deriv=$(${nix-bin-dir}/nix build --no-link --print-out-paths path:.#${sys}Configurations.${hostname}.config.system.build.toplevel)
              ${nvd} --nix-bin-dir=${nix-bin-dir} diff /run/current-system $deriv

              read -p "Continue? [Y/n]: " confirm
              case $confirm in
                y|Y|"")
                  ${doas} nix-env -p /nix/var/nix/profiles/system --set $deriv
                  ${doas} $deriv/${activate};;
                n|N) exit 0;;
                *) echo "that's neither yes or no"; exit 1;;
              esac
            ''
        )
      ];
      stateVersion = "25.05";

      shell.enableBashIntegration = true;
      shellAliases = {
        g = "git";
        gs = "git status";
        gg = "git status -s";
        m = "make";
        v = "nvim";
        ls = "eza --icons=always";
        la = "ls -aa";
        ll = "ls -l";
        lla = "ls -la";
        lt = "eza --tree";
        cp = "cp -i";
        mv = "mv -i";
        rm = "rm -i";
        mkdir = "mkdir -p";
        grep = "grep --color=auto";
      };
      sessionPath = lib.lists.map (x: "${config.home.homeDirectory}/${x}") [
        ".cargo/bin"
        ".local/bin"
        "bin"
      ];
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
      };
    };

    programs = {
      home-manager.enable = true;
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "erasedups" "ignorespace" ];
        historyIgnore = [ "ls" "lt" "lla" "la" "tree" "cd" "z" "pushd" "popd" "exit" ];
        shellOptions = [
          "autocd"
          "checkjobs"
          "checkwinsize"
          "extglob"
          "globstar"
          "nocaseglob"
          "histappend"
        ];
        initExtra = /* bash */  ''
          complete -cf doas
        '';
        bashrcExtra = /* bash */ ''
          td() {
            local session="notes"
            local notes_dir="${cfg.sync-dir}/notes"
            if [ "$TMUX" != "" ]; then
              if ! tmux has-session -t "$session"; then
                tmux new-session -ds "$session" -c "$notes_dir" nvim todos.md
              fi
            else
              tmux new-session -ds "$session" -c "$notes_dir" nvim todos.md
              tmux a -t "$session"
            fi
          }

          gco() {
            local my_branch=$(git branch -a --no-color | \
              sort -u | tr -d " " | fzy)

            if echo "$my_branch" | grep -q "remotes/origin"; then
              my_branch=''${my_branch##remotes/origin/}
            fi
            if echo "$my_branch" | grep -q -P --regexp='\*'; then
              my_branch=''${my_branch##\*}
            fi

            git checkout "$my_branch"
          }

          export PS1='\n[$?] \[\033[1m\]\h: \w\[\033[0m\]\n\[\033[33;1m\]$\[\033[0m\] '
        '';
        logoutExtra = /* bash */ ''
      '';
      };

      readline = {
        enable = true;
        extraConfig = /* bash */ ''
          set editing-mode vi
          set colored-stats on
          set colored-completion-prefix on
          set completion-ignore-case on
        '';
      };

      eza = {
        enable = true;
        enableBashIntegration = true;
      };

      fastfetch.enable = true;
      fd.enable = true;

      fzf = {
        enable = true;
        enableBashIntegration = true;
      };

      git = {
        enable = true;
        aliases = {
          d = "diff";
          c = "commit";
          ca = "commit --amend";
          caa = "commit --amend --no-edit";
          co = "checkout";
          cb = "checkout -b";
          s = "status";
          sw = "switch";
          a = "add";
          aa = "add .";
          ac = "commit -a";
          aca = "commit -a --amend";
          C = "commit -a --amend --no-edit";
          pl = "pull";
          p = "push";
          pu = "push -u origin";
          pf = "push --force-with-lease";
          puf = "push --force-with-lease -u origin";
          f = "fetch";
        };
        delta.enable = true;
        userName = user-conf.github-name;
        userEmail = user-conf.email;
        extraConfig = {
          rerere.enabled = true;
          pull.rebase = true;
          push.default = "current";
          push.autoSetupRemote = true;
        };
        includes = [
          {
            condition = "gitdir:${cfg.work-dir}/**";
            contents = {
              user.name = user-conf.work-gitlab-name;
              user.email = user-conf.work-email;
            };
          }
        ];
      };

      jujutsu = {
        enable = false;
        settings = {
          user.name = user-conf.github-name;
          user.email = user-conf.email;
          ui.editor = "nvim";
          "--scope" = [
            {
              "--when.repositories" = [ "${cfg.work-dir}" ];
              user.name = user-conf.work-gitlab-name;
              user.email = user-conf.work-email;
            }
          ];
        };
      };

      htop.enable = true;
      ripgrep.enable = true;
    };

    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices =
          if hostname == syncthing-server then
            {
              sol.id = "ROFGBXL-IPVQEPW-OJSL7O6-ESRCYLE-EI46JFL-KSX4AF7-FXFIDGD-USAXRAQ";
              ky.id = "UUCQ3DZ-QEF46SM-GK4MTAV-GNHSI4F-ZHC4L2D-U6FY7RC-6INILQA-OYEV2AD";
              answer.id = "ISYIUF2-TKA6QSR-74YFSUM-BW2C76T-JLDH6MR-EPRG7ZR-3XNF46T-G2V54AM";
              jacko.id = "EPIB45M-EYSLN3M-T4NGOGN-Y7LAAR5-PEZHHL2-IOEX55W-OUCLTAI-EEEXEAD";
            } else
            {
              elphelt.id = "FYZX372-3CXKFX3-UNUEYLS-DKSQNIP-WZHMN4P-SJTNMRY-2NY5ZNB-DLLQJQM";
            };

        folders =
          let
            mkFolder = { id, clients }: {
              "${cfg.sync-dir}/${id}" = {
                enable = hostname == syncthing-server || lib.lists.elem hostname clients;
                inherit id;
                label = id;
                devices =
                  if hostname == syncthing-server
                  then clients
                  else [ syncthing-server ];
              };
            };
          in
          lib.mkMerge (lib.lists.map mkFolder [
            {
              id = "notes";
              clients = [ "sol" "ky" "answer" "jacko" ];
            }
            {
              id = "house-notes";
              clients = [ "sol" "ky" "answer" "jacko" ];
            }
            {
              id = "personal";
              clients = [ "sol" "ky" ];
            }
            {
              id = "security";
              clients = [ "sol" "ky" ];
            }
            {
              id = "wallpapers";
              clients = [ "sol" "ky" "answer" ];
            }
          ]);
      };
    };
  };
}
