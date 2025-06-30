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

    # apps
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    { nixpkgs-stable
    , nixpkgs-unstable
    , chaotic
    , home-manager
    , nix-darwin
    , ...
    } @ inputs:
    let
      userConf = {
        name = "tommy";
        github_name = "tbreslein";
        work_gitlab_name = "Tommy Breslein";
        email = "tommy.breslein@protonmail.com";
        work_email = "tommy.breslein@pailot.com";
        monofont = "DepartureMono Nerd Font";
        # monofont = "Terminess Nerd Font";
        # monofont = "Hack Nerd Font";
        terminal = "alacritty";
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

      mkHome = system: hostname:
        let
          args = mkArgs system;
        in
        {
          "${hostname}" = home-manager.lib.homeManagerConfiguration {
            pkgs = args.pkgs-unstable;
            extraSpecialArgs = args;
            modules = [
              ./modules/home
              ./hosts/${hostname}/home.nix
            ];
          };
        };

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
      homeConfigurations =
        (mkHome "x86_64-linux" "kain")
        // (mkHome "x86_64-linux" "raziel");

      nixosConfigurations =
        (mkNixos "x86_64-linux" "sol")
        // (mkNixos "x86_64-linux" "ky");

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          hostname = "tommysmbp";
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
