{ config
, lib
, pkgs-unstable
, ...
}:
let
  cfg = config.myHome.syke;

  codeDir = config.home.homeDirectory + "/code/";

  path = "/home/tommy/.nix-profile/bin:/home/tommy/.nix-profile/bin:/home/tommy/.nix-profile/bin:/home/tommy/.cargo/bin:/home/tommy/.local/bin:/home/tommy/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl";
  setPath = "PATH=${path}:$PATH";
in
{
  options = {
    myHome.syke = {
      enable = lib.mkEnableOption "Enable syke";

      code-repos = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation = lib.mkMerge [
      {
        code-repos =
          let
            clone = remote:
              let
                dir = codeDir + (lib.strings.removeSuffix ".git" (lib.lists.last (builtins.split "/" remote)));
                git = "${pkgs-unstable.git}/bin/git";
                gitConf = "--config core.sshCommand=\"${pkgs-unstable.openssh}/bin/ssh -i ${config.home.homeDirectory}/.ssh/id_rsa\"";
              in
                /* bash */
              ''
                set +o pipefail
                set +e
                if [ ! -d ${dir} ]; then
                  ${git} clone ${remote} ${dir} ${gitConf}
                else
                  pushd ${dir}
                  ${git} pull || true
                  popd
                fi
              '';
          in
          lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "git" "ssh" ]
            (lib.strings.concatLines [
              /*bash*/
              ''
                ${setPath}
                if [ ! -d ${codeDir} ]; then
                  mkdir -p ${codeDir}
                fi
              ''

              (lib.strings.concatMapStringsSep "\n" clone cfg.code-repos)
            ]);
      }
    ];
  };
}
