{
  description = "my dotfiles as a flake";
  inputs = {
    # repositories
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # system management
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    { nixpkgs-stable
    , nixpkgs-unstable
    , chaotic
    , home-manager-stable
    , home-manager-unstable
    , nix-darwin
    , nix-homebrew
    , homebrew-core
    , homebrew-cask
    , homebrew-bundle
    , ...
    } @ inputs:
    let
      username = "tommy";

      mk-user-conf = lib: hostname:
        rec {
          name = username;
          inherit hostname;

          hosts = {
            elphelt = {
              ip = "192.168.178.90";
              is-linux = true;
              syncthing-id = "FYZX372-3CXKFX3-UNUEYLS-DKSQNIP-WZHMN4P-SJTNMRY-2NY5ZNB-DLLQJQM";
            };
            sol = {
              ip = "192.168.178.91";
              is-linux = true;
              syncthing-id = "ROFGBXL-IPVQEPW-OJSL7O6-ESRCYLE-EI46JFL-KSX4AF7-FXFIDGD-USAXRAQ";
            };
            ky = {
              ip = "192.168.178.92";
              is-linux = true;
              syncthing-id = "UUCQ3DZ-QEF46SM-GK4MTAV-GNHSI4F-ZHC4L2D-U6FY7RC-6INILQA-OYEV2AD";
            };
            answer = {
              ip = "192.168.178.93";
              is-linux = false;
              syncthing-id = "ISYIUF2-TKA6QSR-74YFSUM-BW2C76T-JLDH6MR-EPRG7ZR-3XNF46T-G2V54AM";
            };
            jacko = {
              ip = "192.168.178.94";
              is-linux = false;
              syncthing-id = "EPIB45M-EYSLN3M-T4NGOGN-Y7LAAR5-PEZHHL2-IOEX55W-OUCLTAI-EEEXEAD";
            };
          };
          syncthing-server = "elphelt";
          is-syncthing-server = hostname == syncthing-server;

          is-linux = hosts."${hostname}".is-linux;
          is-darwin = hosts."${hostname}".is-darwin;
          home-dir =
            if is-linux
            then "/home/${name}"
            else "/Users/${name}";
          work-dir = "${home-dir}/work";
          code-dir = "${home-dir}/Documents/code";
          dots-dir = "${code-dir}/dotsflake";
          sync-dir = "${home-dir}/sync";

          github-name = "tbreslein";
          work-gitlab-name = "Tommy Breslein";
          email = "tommy.breslein@protonmail.com";
          work-email = "tommy.breslein@pailot.com";
          monofont = "Commit Mono Nerd Font";
          colors = rec {
            primary = {
              background = "1d2021";
              foreground = "d4be98";
              accent = "e78a4e";
              error = normal.red;
              border = primary.accent;
            };
            normal = {
              black = "32302f";
              red = "ea6962";
              green = "a9b665";
              yellow = "d8a657";
              blue = "7daea3";
              magenta = "d3869b";
              cyan = "89b482";
              white = "d4be98";
            };
            bright = normal;
          };
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
                  mk-folder = { id, clients }: {
                    "${sync-dir}/${id}" = {
                      enable = is-syncthing-server || lib.lists.elem hostname clients;
                      inherit id;
                      label = id;
                      devices =
                        if is-syncthing-server
                        then clients
                        else [ syncthing-server ];
                    };
                  };
                in
                lib.mkMerge (lib.lists.map mk-folder [
                  {
                    id = "notes";
                    # clients = [ "sol" "ky" "answer" "jacko" ];
                    clients = [ "sol" ];
                  }
                  # {
                  #   id = "house-notes";
                  #   clients = [ "sol" "ky" "answer" "jacko" ];
                  # }
                  # {
                  #   id = "personal";
                  #   clients = [ "sol" "ky" ];
                  # }
                  # {
                  #   id = "security";
                  #   clients = [ "sol" "ky" ];
                  # }
                  # {
                  #   id = "wallpapers";
                  #   clients = [ "sol" "ky" "answer" ];
                  # }
                ]);
            };
          };
        };

      mk-args = system: hostname:
        let
          pkgs-stable = import nixpkgs-stable { inherit system; };
          user-conf = mk-user-conf pkgs-stable.lib hostname;
        in
        { inherit inputs pkgs-stable user-conf; };

      mk-nixos = version: system: hostname: extraModules:
        let
          args = mk-args system hostname;
          home = "/home/${username}";

          _nixpkgs =
            if version == "stable"
            then nixpkgs-stable
            else nixpkgs-unstable;

          _hm =
            if version == "stable"
            then home-manager-stable
            else home-manager-unstable;
        in
        {
          "${hostname}" = _nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = args;
            modules = [
              ./hosts/${hostname}/configuration.nix
              ./modules/nixos

              _hm.nixosModules.home-manager
              {
                users.users.${username}.home = "${home}";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = args;
                  users.${username} = {
                    imports = [
                      ./modules/home
                      ./hosts/${hostname}/home.nix
                    ];
                  };
                };
              }
            ] ++ extraModules;
          };
        };
    in
    {
      nixosConfigurations =
        (mk-nixos nixpkgs-unstable "x86_64-linux" "sol" [ chaotic.nixosModules.default ])
        // (mk-nixos nixpkgs-unstable "x86_64-linux" "ky" [ chaotic.nixosModules.default ])
        // (mk-nixos nixpkgs-stable "aarch64-linux" "elphelt" [ ]);

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          hostname = "answer";
          home = "/Users/${username}";
          args = mk-args system hostname;
        in
        {
          "${hostname}" =
            nix-darwin.lib.darwinSystem {
              inherit system;
              specialArgs = args;
              modules = [
                ./hosts/${hostname}/configuration.nix
                ./modules/darwin

                nix-homebrew.darwinModules.nix-homebrew
                {
                  nix-homebrew = {
                    enable = true;
                    enableRosetta = true;
                    user = "${username}";
                    taps = {
                      "homebrew/homebrew-core" = homebrew-core;
                      "homebrew/homebrew-cask" = homebrew-cask;
                      "homebrew/homebrew-bundle" = homebrew-bundle;
                    };
                  };
                }

                home-manager-unstable.darwinModules.home-manager
                {
                  users.users.${username}.home = "${home}";
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = args;
                    users.${username} = {
                      imports = [
                        ./modules/home
                        ./hosts/${hostname}/home.nix
                      ];
                    };
                  };
                }
              ];
            };
        };
    };
}
