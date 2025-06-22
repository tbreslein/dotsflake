{ config, lib, pkgs-unstable, userConf, ... }:

{
  imports = [
    ./code
    ./linux
    ./darwin
    ./syke
    ./desktop
  ];


  nix = {
    gc.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';
  };

  home = {
    username = userConf.name;
    packages = with pkgs-unstable; [
      nerd-fonts.hack
      nerd-fonts.terminess-ttf
      nerd-fonts.departure-mono

      ripgrep
      bat
      gitu
      kanata
    ];
    stateVersion = "25.05";

    file.".config/kanata/kanata.kbd".text = /* kbd */ ''
      ;; TODO
    '';

    shell.enableBashIntegration = true;
    shellAliases = {
      g = "git";
      gs = "git status";
      gg = "gitu";
      lg = "lazygit";
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
      TERMINAL = "alacritty";
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
        tm() {
          local homedir="${config.home.homeDirectory}"
          if [ "$TMUX" != "" ]; then
            if ! tmux has-session -t home; then
              tmux new-session -ds "home" -c "$homedir"
            fi
          else
            tmux new-session -ds "home" -c "$homedir"
            tmux a -t "home"
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
            cut -d" " -f2 | \
            awk '{ print substr($0,1,length($0)-1) }')
          task "$selected_task"
        }

        # __ps1_exitstatus() {
        #   local err_code=$?
        #   if [[ $err_code == 0 ]]; then
        #     echo ""
        #   else
        #     echo -e '\[\033[31;1m\]['$err_code']\[\033[0m\]'
        #   fi
        # }
        export PS1='[$?] \[\033[1m\]\W\[\033[0m\] \[\033[1m\]$\[\033[0m\] '
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
        c = "commit";
        ca = "commit --amend";
        caa = "commit --amend --no-edit";
        co = "checkout";
        s = "status";
        sw = "switch";
        a = "add";
        aa = "add .";
        p = "pull";
        P = "push";
        PU = "push -u origin";
        PF = "push --force-with-lease";
        PUF = "push --force-with-lease -u origin";
        f = "fetch";
      };
      delta.enable = true;
      userName = userConf.github_name;
      userEmail = userConf.email;
      extraConfig = {
        rerere.enabled = true;
        pull.rebase = true;
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
      flake = "${config.home.homeDirectory}/dotsflake";
    };

    htop.enable = true;
    lazygit.enable = true;

    ripgrep.enable = true;
  };
}
