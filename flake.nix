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

	outputs = {
		self,
		nixpkgs-stable,
		nixpkgs-unstable,
		home-manager,
	} @ inputs: let
		pkgs-stable = nixpkgs-stable.legacyPackages.x86_64-linux;
		pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
	in {
		nixosConfigurations = {
			raziel = nixpkgs-stable.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = {inherit inputs;};
				modules = [./system/raziel/configuration.nix];
			};
		};

		homeConfiguration = {
			"tommy@raziel" = home-manager.lib.homeManagerConfiguration {
				# pkgs = pkgs-unstable;
				extraSpecialArgs = {inherit inputs pkgs-stable pkgs-unstable;};
				modules = [./home];
			};
		};
	};
}
