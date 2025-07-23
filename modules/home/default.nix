{ config, lib, pkgs, user-conf, ... }:

let
  cfg = config.my-home;
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
  };

  config = lib.mkIf cfg.enable {
    home = {
      username = user-conf.name;
      packages = with pkgs; [
        nerd-fonts.commit-mono

        ripgrep
        fzy
        bat
        rm-improved
        git

        (
          let
            nvd = "${pkgs.nvd}/bin/nvd";
            sys = if pkgs.stdenv.isLinux then "nixos" else "darwin";
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
              sudo ${sys}-rebuild build --flake . && \
                ${nvd} diff /run/current-system result

              read -p "Continue? [Y/n]: " confirm
              case $confirm in
                y|Y|"") sudo ./result/activate switch;;
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
      '';
        bashrcExtra = /* bash */ ''
          td() {
            if [ "$TMUX" != "" ]; then
              if ! tmux has-session -t dotsflake; then
                tmux new-session -ds "dotsflake" -c "${cfg.dots-dir}"
              fi
            else
              tmux new-session -ds "dotsflake" -c "${cfg.dots-dir}"
              tmux a -t "dotsflake"
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

          export PS1='\n[$?] \[\033[1m\]\w\[\033[0m\]\n\[\033[33;1m\]$\[\033[0m\] '
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

      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
        silent = true;
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
        enable = true;
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

      nh = {
        enable = true;
        clean.enable = true;
        flake = "${cfg.dots-dir}";
      };

      htop.enable = true;
      lazygit.enable = true;

      ripgrep.enable = true;
    };
  };
}
