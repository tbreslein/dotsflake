{
  description = "my dotfiles as a flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self
    , nixpkgs-stable
    , nixpkgs-unstable
    , home-manager
    , nix-darwin
    ,
    } @ inputs:
    {
      nixosConfigurations = {
        raziel = let
        pkgs-stable = nixpkgs-stable.legacyPackages.x86_64-linux;
        pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      in nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
          modules = [
            ./system/raziel
            ./modules
            ./modules/code
            ./modules/linux-desktop
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
                users.tommy = ./home;
              };
            }
          ];
        };
      };

      darwinConfigurations."tommysmbp" = let
        pkgs-stable = nixpkgs-stable.legacyPackages.aarch64-darwin;
        pkgs-unstable = nixpkgs-unstable.legacyPackages.aarch64-darwin;
      in nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
        modules = [
          ./hosts/mbp/configuration.nix
          home-manager.darwinModules.home-manager
          {
            users.users.tommy.home = "/Users/tommy";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
              # users.tommy = ./hosts/mbp/home.nix;
              users.tommy = {
                imports = [
                  ./modules/home
                  ./modules/home/code
                  ./hosts/mbp/home.nix
                ];
              };
            };
          }
        ];
      };
    };
}
