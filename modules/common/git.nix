{ config, lib, pkgs, user-conf, ... }:

let
  cfg = config.my-system.git;
in
{
  options.my-system.git.enable = lib.mkEnableOption "Enable git";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name} = {
      home.shellAliases = {
        g = "git";
        gs = "git status";
        gg = "git status -s";
      };
      programs = {
        bash.bashrcExtra = /* bash */ ''
          gco() {
            local my_branch=$(git branch -a --no-color | \
              sort -u | tr -d " " | fzf)

            if echo "$my_branch" | grep -q "remotes/origin"; then
              my_branch=''${my_branch##remotes/origin/}
            fi
            if echo "$my_branch" | grep -q -P --regexp='\*'; then
              my_branch=''${my_branch##\*}
            fi

            git checkout "$my_branch"
          }
        '';

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
              condition = "gitdir:${user-conf.work-dir}/**";
              contents = {
                user.name = user-conf.work-gitlab-name;
                user.email = user-conf.work-email;
              };
            }
          ];
        };
      };
    };
  };
}
