{ config
, lib
, pkgs-unstable
, ...
}:
let
  cfg = config.myHome.syke;

  concatStrList = lib.strings.concatStringsSep " ";
  codeDir = config.home.homeDirectory + "/code/";

  path = "/home/tommy/.nix-profile/bin:/home/tommy/.nix-profile/bin:/home/tommy/.nix-profile/bin:/home/tommy/.cargo/bin:/home/tommy/.local/bin:/home/tommy/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl";
  setPath = "PATH=${path}:$PATH";
in
{
  options = {
    myHome.syke = {
      enable = lib.mkEnableOption "Enable syke";

      arch = {
        enable = lib.mkEnableOption "Enable syke.arch";
        pacman-pkgs = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
        };
        aur-pkgs = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
        };
      };

      systemd = {
        enable = lib.mkEnableOption "Enable syke.systemd";
        services-masked = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
        };
        services-enabled = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
        };
        user-services-enabled = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
        };
      };

      code-repos = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation = lib.mkMerge [
      (lib.mkIf cfg.arch.enable {
        arch-pkgs =
          let
            mk-pkgs = xs: lib.strings.concatStringsSep "\n" xs;
            pacman-pkgs = mk-pkgs cfg.arch.pacman-pkgs;
            aur-pkgs = mk-pkgs cfg.arch.aur-pkgs;

            state-dir = config.home.homeDirectory + "/.local/state/syke";
            awk = "awk";
            yay = "yay";
          in
          lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "awk" ]
            (lib.strings.concatLines [
              /*bash*/
              ''
                ${setPath}

                prep_pkgs() {
                  pkg_manager="''\$1"
                  state_base="${state-dir}/$pkg_manager"

                  current_state="''\${state_base}_current"
                  want="''\${state_base}_want"
                  install="''\${state_base}_install"
                  remove="''\${state_base}_remove"

                  mkdir -p ${state-dir}
                  touch $current_state
                  touch $install
                  touch $remove

                  if [[ "$pkg_manager" == "pacman" ]]; then
                    echo "${pacman-pkgs}" > "$want"
                  elif [[ "$pkg_manager" == "aur" ]]; then
                    echo "${aur-pkgs}" > "$want"
                  else
                    echo "invalid pkg_manager: $pkg_manager"
                    exit 1
                  fi

                  sort -u -o $want $want
                  sort -u -o $current_state $current_state

                  comm -23 "$want" "$current_state" >"$install"
                  comm -13 "$want" "$current_state" >"$remove"
                }

                set -euo pipefail

                prep_pkgs pacman
                pacman_want=$want
                pacman_current=$current_state
                pacman_install=$install
                pacman_remove=$remove

                prep_pkgs aur
                aur_want=$want
                aur_current=$current_state
                aur_install=$install
                aur_remove=$remove

                if [ -s "$pacman_remove" ]; then
                  ${yay} -R $(${awk} '{print $1}' $pacman_remove)
                fi
                if [ -s "$aur_remove" ]; then
                  ${yay} -R $(${awk} '{print $1}' $aur_remove)
                fi

                echo ${yay}

                if [ -s "$pacman_install" ]; then
                  ${yay} --needed -S $(${awk} '{print $1}' $pacman_install)
                fi
                if [ -s "$aur_install" ]; then
                  ${yay} --needed -S $(${awk} '{print $1}' $aur_install)
                fi

                mv $pacman_want $pacman_current
                rm $pacman_install
                rm $pacman_remove

                mv $aur_want $aur_current
                rm $aur_install
                rm $aur_remove
              ''
            ]);
      })

      (lib.mkIf cfg.systemd.enable {
        systemd-services =
          lib.hm.dag.entryAfter [ "writeBoundary" "arch-pkgs" ]
            (lib.strings.concatLines [
              ''
                ${setPath}
              ''

              (if lib.length cfg.systemd.user-services-enabled > 0
              then "systemctl --user enable ${concatStrList cfg.systemd.user-services-enabled}"
              else ""
              )

              (if lib.length cfg.systemd.services-enabled > 0
              then "sudo systemctl enable ${concatStrList cfg.systemd.services-enabled}"
              else ""
              )

              (if lib.length cfg.systemd.services-masked > 0
              then "sudo systemctl mask ${concatStrList cfg.systemd.services-masked}"
              else ""
              )
            ]);
      })

      {
        code-repos =
          let
            clone = remote:
              let dir = codeDir + (lib.strings.removeSuffix ".git" (lib.lists.last (builtins.split "/" remote)));
              in
                /* bash */
              ''
                if [ ! -d ${dir} ]; then
                  git clone ${remote} ${dir} \
                    --config core.sshCommand="${pkgs-unstable.openssh}/bin/ssh -i ${config.home.homeDirectory}/.ssh/id_rsa"
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
