{ config, lib, pkgs-stable, pkgs, hm, user-conf, ... }:

{
  my-system = {
    alacritty.enable = true;
    terminal = "alacritty";
    terminal-font-size = 21;

    has-gui = true;
    kanata.enable = true;

    bash.enable = true;
    syncthing.enable-syncthing-client = true;

    git.enable = true;
    jujutsu.enable = true;

    code = {
      enable = true;
      # emacs.enable = true;
      neovim = {
        enable = true;
        nvim-config = "big";
      };
      zed.enable = true;
    };
    tmux.enable = true;

    aerospace.enable = true;
  };

  homebrew = {
    brews = [
      "gcc"
      "node"
    ];
    casks = [
      "1password"
      "anki"
      "ghostty"
      config.my-system.terminal
      "brave-browser"
    ];
  };

  ${hm}.home = {
    shellAliases.mocostate = "tail -10 /tmp/mococlient.err.log";
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };
  };

  launchd.user.agents = {
    mococlient = {
      command = "${pkgs-stable.poetry}/bin/poetry run python moco_client.py";
      environment.AUTO_STOP_AND_NAG = "False";
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/mococlient.out.log";
        StandardErrorPath = "/tmp/mococlient.err.log";
        WorkingDirectory = "/Users/${user-conf.name}/work/repos/mocotrackingclient";
      };
    };
  };

  programs._1password.enable = true;
}
