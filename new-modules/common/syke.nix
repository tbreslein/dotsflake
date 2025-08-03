{ config, lib, pkgs, hm, user-conf, ... }:
let
  cfg = config.my-system.syke;
  inherit (user-conf) code-dir home-dir;

  path = "/home/tommy/.nix-profile/bin:/home/tommy/.nix-profile/bin:/home/tommy/.nix-profile/bin:/home/tommy/.cargo/bin:/home/tommy/.local/bin:/home/tommy/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl";
  setPath = "PATH=${path}:$PATH";

  default-code-repos =
    if config.my-system.code.enable then
      let
        buildUrl = x: "git@github.com:tbreslein/" + x + ".git";
      in
      lib.lists.map buildUrl [
        "capturedlambdav2"
        "shyr"
        "computer_enhance"
        "public_presentations"
        "private_presentations"
      ]
    else [ ];
in
{
  options.my-system.syke = {
    enable = lib.mkEnableOption "Enable syke";

    code-repos = lib.mkOption {
      type = with lib.types; listOf str;
      default = default-code-repos;
    };
  };

  config = lib.mkIf cfg.enable {
    ${hm}.home.activation = lib.mkMerge [
      {
        code-repos =
          let
            clone = remote:
              let
                dir = code-dir + "/" + (lib.strings.removeSuffix ".git" (lib.lists.last (builtins.split "/" remote)));
                git = "${pkgs.git}/bin/git";
                gitConf = "--config core.sshCommand=\"${pkgs.openssh}/bin/ssh -i ${home-dir}/.ssh/id_rsa\"";
              in
                /* bash */
              ''
                if [ ! -d ${dir} ]; then
                  ${git} clone ${remote} ${dir} ${gitConf} &
                else
                  pushd ${dir}
                  ${git} pull &
                  popd
                fi
              '';
          in
          lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "git" "ssh" ]
            (lib.strings.concatLines [
              /*bash*/
              ''
                set +o pipefail
                set +e

                ${setPath}
                if [ ! -d ${code-dir} ]; then
                  mkdir -p ${code-dir}
                fi
              ''

              (lib.strings.concatMapStringsSep "\n" clone cfg.code-repos)

              ''
                wait
              ''
            ]);
      }
    ];
  };
}
