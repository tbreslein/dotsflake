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
        raziel =
          let
            pkgs-stable = nixpkgs-stable.legacyPackages.x86_64-linux;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          in
          nixpkgs-unstable.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
            modules = [
              ./hosts/raziel/configuration.nix
              home-manager.nixosModules.home-manager
              {
                users.users.tommy.home = "/home/tommy";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
                  users.tommy = {
                    imports = [
                      ./modules/home
                      ./hosts/raziel/home.nix
                    ];
                  };
                };
              }
            ];
          };
      };

      darwinConfigurations."tommysmbp" =
        let
          pkgs-stable = nixpkgs-stable.legacyPackages.aarch64-darwin;
          pkgs-unstable = nixpkgs-unstable.legacyPackages.aarch64-darwin;
        in
        nix-darwin.lib.darwinSystem
          {
            system = "aarch64-darwin";
            specialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
            modules = [
              ./hosts/tommysmbp/configuration.nix
              home-manager.darwinModules.home-manager
              {
                users.users.tommy.home = "/Users/tommy";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
                  users.tommy = {
                    imports = [
                      ./modules/home
                      ./hosts/tommysmbp/home.nix
                    ];
                  };
                };
              }
            ];
          };
    };
}
