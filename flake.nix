{
  description = "my dotfiles as a flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self
    , nixpkgs-stable
    , nixpkgs-unstable
    , home-manager
    ,
    } @ inputs:
    let
      pkgs-stable = nixpkgs-stable.legacyPackages.x86_64-linux;
      pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
    in
    {
      nixosConfigurations = {
        raziel = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
          modules = [
            ./system/raziel/configuration.nix
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
    };
}
