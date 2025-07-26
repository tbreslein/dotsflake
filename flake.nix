{
  description = "my dotfiles as a flake";
  inputs = {
    # repositories
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # system management
    home-manager-stable = {
      url = "github:nix-community/home-manager/25.05";
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

    # apps
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
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
      user-conf = {
        name = "tommy";
        github-name = "tbreslein";
        work-gitlab-name = "Tommy Breslein";
        email = "tommy.breslein@protonmail.com";
        work-email = "tommy.breslein@pailot.com";
        monofont = "Commit Mono Nerd Font";
        # monofont = "DepartureMono Nerd Font";
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

      mkArgs = system: hostname:
        let
          pkgs-stable = import nixpkgs-stable { inherit system; };
        in
        { inherit inputs pkgs-stable user-conf system hostname; };

      mkNixos = version: system: hostname: extraModules:
        let
          args = mkArgs system hostname;
          home = "/home/${user-conf.name}";

          _nixpkgs = if version == "stable"
            then nixpkgs-stable
            else nixpkgs-unstable;

          _hm = if version == "stable"
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
        (mkNixos nixpkgs-unstable "x86_64-linux" "sol" [ chaotic.nixosModules.default ])
        // (mkNixos nixpkgs-unstable "x86_64-linux" "ky" [ chaotic.nixosModules.default ])
        // (mkNixos nixpkgs-stable "aarch64-linux" "elphelt" [ ]);

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          hostname = "answer";
          home = "/Users/${user-conf.name}";
          args = mkArgs system hostname;
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
