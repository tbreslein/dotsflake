{ config, lib, pkgs, user-conf, ... }:

let
  cfg = config.my-system.syncthing;

  inherit (user-conf) hostname syncthing-server hosts;
  is-syncthing-server = hostname == syncthing-server;

  syncthing-config = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices =
        lib.mapAttrs
          (_: v: { id = v.syncthing-id; })
          (if is-syncthing-server
          then (lib.filterAttrs (n: _: n != syncthing-server) hosts)
          else (lib.filterAttrs (n: _: n == syncthing-server) hosts));
      folders =
        let
          host-folders = lib.mapAttrs (n: v: { "${n}" = v.syncthing-folders; });
          all-folders = lib.lists.unique (lib.attrsets.attrValues host-folders);

          mk-folder = id: {
            "${user-conf.sync-dir}/${id}" = {
              enable = true;
              inherit id;
              label = id;
              devices =
                if is-syncthing-server
                then
                  let
                    # from host-folders, pull out all the attribute names where
                    # this folder-id is an element of the syncthing-folders.
                    # also filter out this hostname, because we don't want the
                    # syncthing-server to share folders with itself.
                    _filter = n: v: n != hostname && lib.lists.elem id v;
                  in
                  lib.attrsets.attrNames (lib.filterAttrs _filter host-folders)
                else [ syncthing-server ];
            };
          };
        in
        lib.mkMerge (lib.lists.map mk-folder all-folders);
    };
  };
in
{
  options.my-system.syncthing = {
    enable-syncthing-client = lib.mkEnableOption "Enable syncthing as a client";
    enable-syncthing-server = lib.mkEnableOption "Enable syncthing as a server";
  };

  config = lib.mkMerge [
    (lib.mkIf user-conf.is-linux {
      services.syncthing = { openDefaultPorts = true; } // (
        if cfg.enable-syncthing-server
        then {
          user = user-conf.name;
          configDir = "${user-conf.home-dir}/.config/syncthing";
        } // user-conf.syncthing-config
        else { }
      );
    })

    (lib.mkIf cfg.enable-syncthing-client {
      home-manager.users.${user-conf.name}.services.syncthing =
        lib.mkIf cfg.enable-syncthing-client user-conf.syncthing-config;
    })
  ];
}
