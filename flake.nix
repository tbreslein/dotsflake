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
      mk-syncthing-config = config: lib: hostname:
        let
          inherit (config.home.my-home) sync-dir syncthing-server;
        in
        {
          enable = true;
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            devices =
              if hostname == syncthing-server then
                {
                  sol.id = "ROFGBXL-IPVQEPW-OJSL7O6-ESRCYLE-EI46JFL-KSX4AF7-FXFIDGD-USAXRAQ";
                  ky.id = "UUCQ3DZ-QEF46SM-GK4MTAV-GNHSI4F-ZHC4L2D-U6FY7RC-6INILQA-OYEV2AD";
                  answer.id = "ISYIUF2-TKA6QSR-74YFSUM-BW2C76T-JLDH6MR-EPRG7ZR-3XNF46T-G2V54AM";
                  jacko.id = "EPIB45M-EYSLN3M-T4NGOGN-Y7LAAR5-PEZHHL2-IOEX55W-OUCLTAI-EEEXEAD";
                } else
                {
                  elphelt.id = "FYZX372-3CXKFX3-UNUEYLS-DKSQNIP-WZHMN4P-SJTNMRY-2NY5ZNB-DLLQJQM";
                };
            folders =
              let
                mk-folder = { id, clients }: {
                  "${sync-dir}/${id}" = {
                    enable = hostname == syncthing-server || lib.lists.elem hostname clients;
                    inherit id;
                    label = id;
                    devices =
                      if hostname == syncthing-server
                      then clients
                      else [ syncthing-server ];
                  };
                };
              in
              lib.mkMerge (lib.lists.map mk-folder [
                {
                  id = "notes";
                  clients = [ "sol" "ky" "answer" "jacko" ];
                }
                {
                  id = "house-notes";
                  clients = [ "sol" "ky" "answer" "jacko" ];
                }
                {
                  id = "personal";
                  clients = [ "sol" "ky" ];
                }
                {
                  id = "security";
                  clients = [ "sol" "ky" ];
                }
                {
                  id = "wallpapers";
                  clients = [ "sol" "ky" "answer" ];
                }
              ]);
          };
        };

      user-conf = {
        name = "tommy";
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
        hosts = {
          "192.168.178.90" = [ "elphelt" ];
          "192.168.178.91" = [ "sol" ];
          "192.168.178.92" = [ "ky" ];
          "192.168.178.93" = [ "answer" ];
          "192.168.178.94" = [ "jacko" ];
          "192.168.178.95" = [ "Tworkphone" ];
        };
      };

      mk-args = system: hostname:
        let
          pkgs-stable = import nixpkgs-stable { inherit system; };
        in
        { inherit inputs pkgs-stable user-conf system hostname mk-syncthing-config; };

      mk-nixos = version: system: hostname: extraModules:
        let
          args = mk-args system hostname;
          home = "/home/${user-conf.name}";

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
                users.users.${user-conf.name}.home = "${home}";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = args;
                  users.${user-conf.name} = {
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
          home = "/Users/${user-conf.name}";
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
                    user = "${user-conf.name}";
                    taps = {
                      "homebrew/homebrew-core" = homebrew-core;
                      "homebrew/homebrew-cask" = homebrew-cask;
                      "homebrew/homebrew-bundle" = homebrew-bundle;
                    };
                  };
                }

                home-manager-unstable.darwinModules.home-manager
                {
                  users.users.${user-conf.name}.home = "${home}";
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = args;
                    users.${user-conf.name} = {
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
