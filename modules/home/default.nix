{ config, lib, pkgs-unstable, userConf, ... }:

{
  imports = [
    ./code
    ./linux
    ./darwin
    ./syke
    ./desktop
    ./laptop
  ];

  home = {
    username = userConf.name;
    packages = with pkgs-unstable; [
      nerd-fonts.commit-mono
      nerd-fonts.departure-mono

      ripgrep
      fzy
      bat
      rm-improved

      (writeShellScriptBin "dm" /*bash*/ ''
        os=""
        case $(uname -s) in
          Linux) os="os";;
          Darwin) os="darwin";;
        esac
        case $1 in
          u) nh $os switch -u;;
          *) nh $os switch;;
        esac
      '')
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
      TERMINAL = "${userConf.terminal}";
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
      profileExtra = /* bash */ ''
        [[ -f "/opt/homebrew/bin/brew" ]] && \
          eval "$(/opt/homebrew/bin/brew shellenv)"
        [[ -f "${config.home.homeDirectory}/.cargo/env" ]] && \
          source "${config.home.homeDirectory}/.cargo/env"
      '';
      initExtra = /* bash */  ''
      '';
      bashrcExtra = /* bash */ ''
        td() {
          local dotsflake="${config.home.homeDirectory}/dotsflake"
          if [ "$TMUX" != "" ]; then
            if ! tmux has-session -t dotsflake; then
              tmux new-session -ds "dotsflake" -c "$dotsflake"
            fi
          else
            tmux new-session -ds "dotsflake" -c "$dotsflake"
            tmux a -t "dotsflake"
          fi
        }

        toggle_kanata() {
          local kanatadir="${config.home.homeDirectory}/.config/kanata/"
          if ! tmux has-session -t "kanata" 2>/dev/null; then
            tmux new-session -ds "kanata" -c "$kanatadir"
            ${if config.myHome.linux.enable
              then "tmux send-keys -t kanata 'kanata -c ./kanata.kbd' C-m"
              else ("tmux send-keys -t kanata 'sudo kanata -c ./kanata.kbd'" +
                " && tmux switch-client -t kanata")}
          else
            tmux kill-session -t "kanata"
          fi
        }

        toggle_moco() {
          local mocodir="${config.home.homeDirectory}/work/repos/mocotrackingclient"
          if ! tmux has-session -t "moco" 2>/dev/null; then
            tmux new-session -ds "moco" -c "$mocodir"
            tmux send-keys -t "moco" "poetry install; AUTO_STOP_AND_NAG=False poetry run python moco_client.py" C-m
          else
            tmux kill-session -t "moco"
          fi
        }

        twork() {
          local workdir="${config.home.homeDirectory}/work"
          if [ "$TMUX" != "" ]; then
            pushd "$workdir" || exit
            toggle_moco
            popd || exit
            if ! tmux has-session -t work; then
              tmux new-session -ds "work" -c "$workdir"
            fi
          else
            tmux new-session -ds "work" -c "$workdir"
            tmux send-keys -t "work" "toggle_moco" C-m
            tmux a -t "work"
          fi
        }

        gco() {
          local my_branch=$(git branch -a --no-color | \
            sort | \
            uniq | \
            tr -d " " | \
            fzf --select-1 --ansi --preview 'git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" {} 2>/dev/null')

          if echo "$my_branch" | grep -q "remotes/origin"; then
            my_branch=''${my_branch##remotes/origin/}
          fi
          if echo "$my_branch" | grep -q -P --regexp='\*'; then
            my_branch=''${my_branch##\*}
          fi

          git checkout "$my_branch"
        }

        ft() {
          local selected_task=$(task --list | \
            grep '^\\*' | \
            fzf | \
            awk '{ print substr($2,1,length($2)-1) }')
          task "$selected_task"
        }

        export PS1='[$?] \[\033[1m\]\W\[\033[0m\] \[\033[33;1m\]$\[\033[0m\] '
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
      userName = userConf.github_name;
      userEmail = userConf.email;
      extraConfig = {
        rerere.enabled = true;
        pull.rebase = true;
        push.default = "current";
        push.autoSetupRemote = true;
      };
      includes = [
        {
          condition = "gitdir:${config.home.homeDirectory}/work/**";
          contents = {
            user.name = userConf.work_gitlab_name;
            user.email = userConf.work_email;
          };
        }
      ];
    };

    jujutsu = {
      enable = true;
      settings = {
        user.name = userConf.github_name;
        user.email = userConf.email;
        ui.editor = "nvim";
        "--scope" = [
          {
            "--when.repositories" = [ "${config.home.homeDirectory}/work" ];
            user.name = userConf.work_gitlab_name;
            user.email = userConf.work_email;
          }
        ];
      };
    };

    nh = {
      enable = true;
      clean.enable = true;
      flake = "${config.home.homeDirectory}/dotsflake";
    };

    htop.enable = true;
    lazygit.enable = true;

    ripgrep.enable = true;
  };
}
