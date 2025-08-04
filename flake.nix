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

      mk-user-conf = lib: system: hostname:
        rec {
          name = username;
          inherit hostname system;
          inherit (hosts."${hostname}") is-linux is-darwin;
          home-dir =
            if is-linux
            then "/home/${name}"
            else "/Users/${name}";
          work-dir = "${home-dir}/work";
          code-dir = "${home-dir}/code";
          dots-dir = "${home-dir}/dotsflake";
          sync-dir = "${home-dir}/sync";

          hosts = {
            elphelt = {
              ip = "192.168.178.90";
              is-linux = true;
              syncthing-id = "ZZTPUBC-UHGT3I5-YOAXZF3-UDQHGE3-FE5XFMA-B6SQWSW-AKGD3UI-BTBB3QV";
              syncthing-folders = [ "notes" "house-notes" "personal" "security" "wallpapers" ];
            };
            sol = {
              ip = "192.168.178.91";
              is-linux = true;
              syncthing-id = "ROFGBXL-IPVQEPW-OJSL7O6-ESRCYLE-EI46JFL-KSX4AF7-FXFIDGD-USAXRAQ";
              syncthing-folders = [ "notes" "house-notes" "personal" "security" "wallpapers" ];
            };
            ky = {
              ip = "192.168.178.92";
              is-linux = true;
              syncthing-id = "UUCQ3DZ-QEF46SM-GK4MTAV-GNHSI4F-ZHC4L2D-U6FY7RC-6INILQA-OYEV2AD";
              syncthing-folders = [ "notes" "house-notes" "personal" "security" "wallpapers" ];
            };
            answer = {
              ip = "192.168.178.93";
              is-linux = false;
              syncthing-id = "ISYIUF2-TKA6QSR-74YFSUM-BW2C76T-JLDH6MR-EPRG7ZR-3XNF46T-G2V54AM";
              syncthing-folders = [ "notes" "house-notes" "wallpapers" ];
            };
            jacko = {
              ip = "192.168.178.94";
              is-linux = false;
              syncthing-id = "EPIB45M-EYSLN3M-T4NGOGN-Y7LAAR5-PEZHHL2-IOEX55W-OUCLTAI-EEEXEAD";
              syncthing-folders = [ "notes" "house-notes" ];
            };
          };
          syncthing-server = "elphelt";

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
        };

      mk-args = system: hostname: hm:
        let
          pkgs-stable = import nixpkgs-stable { inherit system; };
          user-conf = mk-user-conf pkgs-stable.lib system hostname;
        in
        { inherit inputs pkgs-stable hm user-conf; };

      mk-nixos = version: system: hostname: extraModules: include-hm:
        let
          args = mk-args system hostname "home-manager.users.${username}";

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
              ./new-hosts/${hostname}
              ./new-modules/nixos
              _hm.nixosModules.home-manager
              {
                users.users.${username}.home = "${args.user-conf.home-dir}";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                };
              }
            ];
            # modules = [
            #   ./hosts/${hostname}/configuration.nix
            #   ./modules/nixos
            # ]
            # ++ extraModules
            # ++ (if include-hm then [
            #   _hm.nixosModules.home-manager
            #   {
            #     users.users.${username}.home = "${home}";
            #     home-manager = {
            #       useGlobalPkgs = true;
            #       useUserPackages = true;
            #       extraSpecialArgs = args;
            #       users.${username} = {
            #         imports = [
            #           ./modules/home
            #           ./hosts/${hostname}/home.nix
            #         ];
            #       };
            #     };
            #   }
            # ] else [ ]);
          };
        };
    in
    {
      nixosConfigurations =
        (mk-nixos nixpkgs-unstable "x86_64-linux" "sol" [ chaotic.nixosModules.default ] true)
        // (mk-nixos nixpkgs-unstable "x86_64-linux" "ky" [ chaotic.nixosModules.default ] true)
        // (mk-nixos nixpkgs-stable "aarch64-linux" "elphelt" [ ] false);

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
