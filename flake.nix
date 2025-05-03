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
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs-stable.lib.genAttrs supportedSystems;

      mkSystem = system: hostname:
        let
          pkgs-stable = nixpkgs-stable.legacyPackages.${system};
          pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          isLinux = pkgs-stable.lib.hasSuffix system "-linux";

          sysfunc =
            if isLinux
            then nixpkgs-unstable.lib.nixosSystem
            else nix-darwin.lib.darwinSystem;
          hmModules =
            if isLinux
            then home-manager.nixosModules.home-manager
            else home-manager.darwinModules.home-manager;
          home =
            if isLinux
            then "/home/tommy"
            else "/Users/tommy";
          uname =
            if isLinux
            then "linux"
            else "darwin";
        in
        {
          "${hostname}" = sysfunc {
            inherit system;
            specialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
            modules = [
              ./hosts/${hostname}/configuration.nix
              ./modules/system/desktop/${uname}

              (if isLinux
              then { networking.hostName = hostname; }
              else { networking.computerName = hostname; })

              hmModules
              {
                users.users.tommy.home = "${home}";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit inputs pkgs-stable pkgs-unstable; };
                  users.tommy = {
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
        (mkSystem "x86_64-linux" "kain") //
        (mkSystem "x86_64-linux" "raziel");
      darwinConfigurations = mkSystem "aarch64-darwin" "tommysmbp";

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
          homeRoot = if pkgs.lib.hasSuffix system "linux" then "/home" else "/Users";
          flakeDir = "${homeRoot}/tommy/dotsflake";
          upgradeCmd =
            let
              cmdPrefix =
                if pkgs.lib.hasSuffix system "linux"
                then "sudo nixos"
                else "darwin";
            in
            "${cmdPrefix}-rebuild switch --flake ${flakeDir}";
          updateCmd = "nix flake update --flake ${flakeDir}";
        in
        rec {
          syke = pkgs.writeShellScriptBin "syke" /* bash */ ''
            update() {
              ${updateCmd}
            }
            upgrade() {
              ${upgradeCmd}
            }
            sync() {
              update
              upgrade
            }

            if [[ $# -eq 0 ]]; then
              sync
              exit 0
            fi

            while [[ $# -gt 0 ]] do
              case $1 in
                update)
                  update
                  shift
                  ;;
                upgrade)
                  upgrade
                  shift
                  ;;
                sync)
                  sync
                  shift
                  ;;
              esac
            done
          '';

          default = syke;
        });

      apps = forAllSystems (system: rec {
        syke = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/syke";
        };
        default = syke;
      });
    };
}
