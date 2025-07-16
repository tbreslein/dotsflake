{
  description = "my dotfiles as a flake";
  inputs = {
    # repositories
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # system management
    home-manager = {
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
    , home-manager
    , nix-darwin
    , nix-homebrew
    , homebrew-core
    , homebrew-cask
    , homebrew-bundle
    , ...
    } @ inputs:
    let
      userConf = rec {
        name = "tommy";
        codeDir = "Documents/code"; # relative to ~
        dotsDir = "${codeDir}/dotsflake"; # relative to ~
        github_name = "tbreslein";
        work_gitlab_name = "Tommy Breslein";
        email = "tommy.breslein@protonmail.com";
        work_email = "tommy.breslein@pailot.com";
        # monofont = "Commit Mono Nerd Font";
        monofont = "DepartureMono Nerd Font";
        terminal = "ghostty";
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

      mkArgs = system:
        let
          pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
          pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
        in
        { inherit inputs pkgs-stable pkgs-unstable userConf system; };

      mkNixos = system: hostname:
        let
          args = mkArgs system;
          home = "/home/${userConf.name}";
        in
        {
          "${hostname}" = nixpkgs-unstable.lib.nixosSystem {
            inherit system;
            specialArgs = args;
            modules = [
              ./hosts/${hostname}/configuration.nix
              ./modules/nixos
              chaotic.nixosModules.default

              home-manager.nixosModules.home-manager
              {
                users.users.${userConf.name}.home = "${home}";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = args;
                  users.${userConf.name} = {
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
    in
    {
      nixosConfigurations =
        (mkNixos "x86_64-linux" "sol")
        // (mkNixos "x86_64-linux" "ky");

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          hostname = "answer";
          home = "/Users/${userConf.name}";
          args = mkArgs system;
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
                    user = "${userConf.name}";
                    taps = {
                      "homebrew/homebrew-core" = homebrew-core;
                      "homebrew/homebrew-cask" = homebrew-cask;
                      "homebrew/homebrew-bundle" = homebrew-bundle;
                    };
                  };
                }

                home-manager.darwinModules.home-manager
                {
                  users.users.${userConf.name}.home = "${home}";
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = args;
                    users.${userConf.name} = {
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
